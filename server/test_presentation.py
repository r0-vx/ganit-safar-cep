"""Presentation/live isolation and serverless transport regressions."""
import importlib
import os
import tempfile
import unittest
from unittest.mock import patch

import app
import presentation


class PresentationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.schemas = []
        self.base_url = os.environ.get('GANIT_TEST_DATABASE_URL', '')
        settings = {'GANIT_PRESENTATION_ENABLED': '1'}
        if self.base_url:
            self.schemas = ['ganit_test_live_' + app.uid(), 'ganit_test_demo_' + app.uid()]
            settings.update(GANIT_DB_SCHEMA=self.schemas[0], GANIT_PRESENTATION_SCHEMA=self.schemas[1])
        self.env = patch.dict(os.environ, settings)
        self.env.start()
        self.old_db, self.old_url = app.DB, app.DATABASE_URL
        app.DB, app.DATABASE_URL = self.tmp.name + '/live.sqlite3', self.base_url
        app.init()
        self.wsgi = importlib.import_module('wsgi')
        self.client = self.wsgi.application.test_client()
        self.password = 'presentation-test-password-2026'
        presentation.prepare(self.password, self.password)
        app.create_user('admin@test.local','Administrator','super_admin',self.password)
        app.create_user('viewer@test.local','Viewer','viewer',self.password)
        app.create_user('school@test.local','School administrator','school_admin',self.password)

    def tearDown(self):
        app.DB, app.DATABASE_URL = self.old_db, self.old_url
        if self.base_url:
            import psycopg
            from psycopg import sql
            with psycopg.connect(self.base_url, autocommit=True) as c:
                for schema in self.schemas:
                    c.execute(sql.SQL('DROP SCHEMA {} CASCADE').format(sql.Identifier(schema)))
        self.env.stop()
        self.tmp.cleanup()

    def login(self, email='admin@test.local'):
        return self.client.post('/api/login',json={'email':email,'password':self.password,'installationId':'workflow-browser-123456789'},headers={'Origin':app.ORIGIN})

    def auth(self,email='admin@test.local'):
        result=self.login(email)
        self.assertEqual(result.status_code,200)
        return {'Authorization':'Bearer '+result.json['token'],'X-Installation-ID':'workflow-browser-123456789','Origin':app.ORIGIN}

    def test_demo_requires_live_super_admin_and_never_changes_live_records(self):
        self.assertEqual(self.client.get('/api/dashboard/demo').status_code,401)
        headers=self.auth()
        with patch.dict(os.environ,{'GANIT_APP_SURFACE':'dashboard'}):
            demo=self.client.get('/api/dashboard/demo',headers=headers)
        self.assertEqual(demo.status_code,200)
        self.assertEqual(demo.json['dataMode'],'presentation')
        self.assertEqual(demo.json['overview']['classrooms'],4)
        live=self.client.get('/api/dashboard',headers=headers)
        self.assertEqual(live.json['overview']['classrooms'],0)
        self.assertEqual(live.json['analytics']['weeklyUsage'],0)
        self.assertFalse(app.is_presentation())

    def test_preview_denied_to_other_roles_and_to_classroom_host(self):
        for email in ['viewer@test.local','school@test.local']:
            headers=self.auth(email)
            self.assertEqual(self.client.get('/api/dashboard/demo',headers=headers).status_code,403)
        headers=self.auth()
        with patch.dict(os.environ,{'GANIT_APP_SURFACE':'classroom'}):
            self.assertEqual(self.client.get('/api/dashboard/demo',headers=headers).status_code,403)

    def test_old_demo_sign_in_and_read_routes_are_not_public(self):
        for path in ['/api/presentation/health','/api/presentation/dashboard','/presentation/health']:
            self.assertEqual(self.client.get(path).status_code,404)
        self.assertEqual(self.client.post('/api/presentation/login',json={'email':'admin','password':'admin'}).status_code,404)
        self.assertFalse(presentation.prepare(self.password,self.password))

    def test_school_classroom_enrollment_monitoring_and_refresh(self):
        headers=self.auth()
        school=self.client.post('/api/schools',headers=headers,json={'name':'Workflow school','code':''})
        self.assertEqual(school.status_code,201)
        school_id=school.json['id']
        room=self.client.post('/api/classrooms',headers=headers,json={'school_id':school_id,'name':'Class 1 A','grade':1})
        self.assertEqual(room.status_code,201)
        rid=room.json['id']
        snapshot=self.client.get('/api/dashboard',headers=headers).json
        self.assertEqual(snapshot['classrooms'][0]['school_id'],school_id)
        self.assertTrue(snapshot['schools'][0]['code'].startswith('SCH-'))
        with patch.dict(os.environ,{'GANIT_APP_SURFACE':'classroom'}):
            enrolled=self.client.post('/api/devices/register',headers=headers,json={'id':'workflow-browser-123456789','installationId':'workflow-browser-123456789','name':'Workflow board','classroom_id':rid})
            self.assertEqual(enrolled.status_code,201)
            self.assertIn('offlineLease',enrolled.json)
            headers['Authorization']='Bearer '+enrolled.json['token']
            beat=self.client.post('/api/devices/workflow-browser-123456789/heartbeat',headers=headers,json={'classroomId':rid,'mode':'learn','grade':1,'chapterId':'G1-C10','version':'1.2.0'})
            self.assertEqual(beat.status_code,200)
            refreshed=self.client.post('/api/auth/refresh',headers=headers,json={'installationId':'workflow-browser-123456789'})
            self.assertEqual(refreshed.status_code,200)
            self.assertIn('offlineLease',refreshed.json)
            headers['Authorization']='Bearer '+refreshed.json['token']
        monitored=self.client.get('/api/dashboard',headers=headers).json
        self.assertEqual(monitored['overview']['activeLessons'],1)
        self.assertEqual(monitored['overview']['onlineClassrooms'],1)

    def test_validation_and_duplicate_school_code_are_reviewable_errors(self):
        headers=self.auth()
        self.assertEqual(self.client.post('/api/schools',headers=headers,json={'name':''}).status_code,400)
        first=self.client.post('/api/schools',headers=headers,json={'name':'One','code':'CODE'})
        self.assertEqual(first.status_code,201)
        self.assertEqual(self.client.post('/api/schools',headers=headers,json={'name':'Two','code':'CODE'}).status_code,409)
        self.assertEqual(self.client.post('/api/classrooms',headers=headers,json={'name':'Invalid','school_id':first.json['id'],'grade':0}).status_code,400)

    def test_vercel_unconfigured_database_never_returns_fake_success(self):
        with patch.object(app,'DATABASE_URL',''),patch.dict(os.environ,{'VERCEL':'1'}):
            self.assertEqual(self.client.get('/api/health').status_code,503)

    def test_vercel_host_and_https_are_both_required(self):
        with patch.object(app,'ENV','production'),patch.object(app,'DATABASE_URL','configured'),patch.dict(os.environ,{'VERCEL':'1','GANIT_ALLOWED_ORIGINS':'https://dashboard.example.test'}):
            self.assertEqual(self.client.get('/api/health',base_url='https://evil.example.test',headers={'X-Forwarded-Proto':'https'}).status_code,400)
            self.assertEqual(self.client.get('/api/health',base_url='https://dashboard.example.test').status_code,400)


if __name__=='__main__': unittest.main()
