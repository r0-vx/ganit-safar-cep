"""Explicit administrative commands. Passwords are read privately, never argv."""
import argparse
import base64
import getpass
import secrets

import app


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['migrate', 'create-admin', 'generate-key', 'prune'])
    parser.add_argument('--email')
    parser.add_argument('--name', default='System administrator')
    args = parser.parse_args()
    if args.command == 'generate-key':
        print(base64.urlsafe_b64encode(secrets.token_bytes(32)).decode().rstrip('='))
        return
    app.init()
    if args.command == 'create-admin':
        if not args.email:
            parser.error('--email is required')
        password = getpass.getpass('New administrator password (12+ characters): ')
        if password != getpass.getpass('Repeat password: '):
            raise SystemExit('Passwords differ')
        app.create_user(args.email, args.name, 'super_admin', password)
        print('Administrator created. No password was saved in plaintext.')
    elif args.command == 'prune':
        import time
        now = time.time()
        with app.connection() as db:
            for table, column, days in [('heartbeats', 'at', 30), ('activity_events', 'occurred_at', 30), ('error_events', 'at', 30), ('audit_logs', 'at', 180), ('sessions', 'expires', 1), ('refresh_tokens', 'expires', 30), ('device_sessions', 'expires', 30), ('password_reset_tokens', 'expires', 1), ('login_attempts', 'started_at', 1)]:
                db.execute(f'DELETE FROM {table} WHERE {column}<?', (now - days * 86400,))
        print('Retention applied; daily aggregate usage is retained.')
    else:
        print('Migrations applied successfully.')


if __name__ == '__main__':
    main()
