"""Explicit, idempotent setup of an isolated presentation dataset.

Never called by a page load or a live request. Credentials come from operator
input/environment, and no simulated online devices are created.
"""
import os
import time
from datetime import datetime, timedelta, timezone

import app


def prepare(teacher_password, viewer_password):
    if min(len(teacher_password), len(viewer_password)) < 12:
        raise ValueError('Presentation passwords must contain at least 12 characters')
    if os.environ.get('GANIT_PRESENTATION_ENABLED') != '1':
        raise ValueError('Enable the isolated presentation environment explicitly')
    app.init()
    with app.dataset(True):
        with app.connection() as c:
            exists = c.execute("SELECT id FROM schools WHERE code='PRESENTATION-ONLY'").fetchone()
        if exists:
            return False
        teacher = app.create_user('teacher@demo.ganitsafar.local', 'Presentation teacher', 'teacher', teacher_password)
        viewer = app.create_user('presenter@demo.ganitsafar.local', 'Presentation viewer', 'viewer', viewer_password)
        now = time.time()
        sid = 'presentation-school'
        with app.connection() as c:
            c.execute('INSERT INTO schools(id,name,code,location,created_at) VALUES(?,?,?,?,?)',
                      (sid, 'Presentation school (demo)', 'PRESENTATION-ONLY', 'Sample classroom environment', now))
            c.execute('INSERT INTO alert_rules(school_id) VALUES(?)', (sid,))
            for user in (teacher, viewer):
                c.execute('INSERT INTO user_schools VALUES(?,?)', (user, sid))
            for grade in range(1, 5):
                rid = f'presentation-class-{grade}'
                c.execute('INSERT INTO classrooms(id,name,school,grade,teacher_id,school_id,section,status,created_at) VALUES(?,?,?,?,?,?,?,?,?)',
                          (rid, f'Demo Class {grade}', 'Presentation school (demo)', grade, teacher, sid, 'A', 'active', now))
                c.execute('INSERT INTO classroom_assignments VALUES(?,?)', (rid, teacher))
                # Sample chart history only. No fake heartbeats, devices,
                # "current" lessons or verified event rows are inserted.
                for days_ago in range(7):
                    day = (datetime.now(timezone.utc) - timedelta(days=days_ago)).date().isoformat()
                    for offset, mode in enumerate(('learn', 'practice', 'quiz')):
                        count = (grade + days_ago + offset) % 5 + 1
                        c.execute('INSERT INTO usage_daily VALUES(?,?,?,?,?,?)',
                                  (day, rid, mode, count, max(0, count - 1), count * 120))
            c.execute('INSERT INTO app_versions VALUES(?,?,?,?,?) ON CONFLICT DO NOTHING', ('1.2.0', 1, 1, now, now))
            app.audit(c, 'setup', 'presentation_sample_history_created', sid, sid)
    return True


if __name__ == '__main__':
    import getpass
    teacher_password = os.environ.get('GANIT_DEMO_TEACHER_PASSWORD') or getpass.getpass('Presentation teacher password: ')
    viewer_password = os.environ.get('GANIT_DEMO_VIEWER_PASSWORD') or getpass.getpass('Presentation viewer password: ')
    print('Presentation dataset created.' if prepare(teacher_password, viewer_password) else 'Presentation dataset already exists; no data or password changed.')
