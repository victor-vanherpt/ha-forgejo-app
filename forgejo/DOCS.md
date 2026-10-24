# Home Assistant App: Forgejo

## Installation

1. Add this repository to Home Assistant and install the **Forgejo** app.
2. Start the app and select **Open Web UI**.
3. Register an account. **The first account registered becomes the
   administrator.**
4. Turn on **Service → Disable registration** and restart the app, unless
   you want anyone who can reach Forgejo to be able to sign up.

## Configuration

The options are grouped like the sections of Forgejo's `app.ini`, and each
option is the lowercased `app.ini` key. See the
[Forgejo configuration cheat sheet](https://forgejo.org/docs/latest/admin/config-cheat-sheet/)
for what each setting does.

| Option | `app.ini` |
| --- | --- |
| `server.root_url` | `[server] ROOT_URL` |
| `server.ssh_domain` | `[server] SSH_DOMAIN` |
| `server.ssh_port` | `[server] SSH_PORT` |
| `service.disable_registration` | `[service] DISABLE_REGISTRATION` |
| `database.db_type` | `[database] DB_TYPE` |
| `database.host` | `[database] HOST` |
| `database.name` | `[database] NAME` |
| `database.user` | `[database] USER` |
| `database.passwd` | `[database] PASSWD` |
| `database.ssl_mode` | `[database] SSL_MODE` |
| `database.schema` | `[database] SCHEMA` |
| `log.level` | `[log] LEVEL` |

Options are written to `app.ini` on every start. Options you leave empty
don't touch `app.ini`, so you can also change those settings by editing the
file directly.

### Extra settings (`env_vars`)

Any other setting can be set with Forgejo's environment override naming,
`FORGEJO__<section>__<KEY>`. For example, to enable email:

```yaml
env_vars:
  - name: FORGEJO__mailer__ENABLED
    value: "true"
  - name: FORGEJO__mailer__PROTOCOL
    value: smtps
  - name: FORGEJO__mailer__SMTP_ADDR
    value: smtp.example.com
```

Use `DEFAULT` as section for top-level keys (`FORGEJO__DEFAULT__APP_NAME`).
In section names, write `.` as `_0X2E_` and `-` as `_0X2D_`
(`FORGEJO__repository_0X2E_signing__DEFAULT_TRUST_MODEL`).

### Editing `app.ini`

`app.ini` is in the app's configuration folder: `/addon_configs/<id>_forgejo/app.ini`
from the Samba or Studio Code Server apps. Templates and static files for
[customizing Forgejo](https://forgejo.org/docs/latest/contributor/customization/)
go in the `custom` folder next to it. Restart the app after changing them.

## Database

By default Forgejo uses SQLite, stored inside the app, which is enough for
personal and small team use.

### MariaDB app

1. In the MariaDB app configuration, add a `forgejo` database and give the
   login you want to use rights to it.
2. Set **Database type** to `mysql` and leave **Host** empty.

The app then picks up the host and credentials from the MariaDB app. Set
**Host**, **User** and **Password** yourself to use different credentials.

### External PostgreSQL or MySQL

Set **Database type**, **Host** (`host:port`), **Database name**, **User** and
**Password**. The database must already exist. The app waits up to 60 seconds
for the database server to come up.

Changing the database type does not move existing data. To migrate, use
[`forgejo dump`](https://forgejo.org/docs/latest/admin/command-line/#dump).

## Git over SSH

Forgejo runs its own SSH server on port 2222. Clone URLs look like
`ssh://git@homeassistant.local:2222/user/repo.git`. Add your public key under
**Settings → SSH / GPG keys** in Forgejo.

If you change the host port in the **Network** section, or reach SSH through a
different port or name (for example a router port forward), set
`server.ssh_port` and `server.ssh_domain` to match, so Forgejo shows the
right clone URLs.

## Reverse proxy

Forgejo can't run under Home Assistant's ingress, because it needs to know
the URL it's served on. To make it reachable on your own domain, put a
reverse proxy (such as the NGINX Proxy Manager app) in front of port 3000 and
set `server.root_url` to the public URL, e.g. `https://git.example.com/`.

## Backups

Repositories, LFS objects, attachments and the SQLite database are in the
app's data folder. `app.ini` is in its configuration folder. Both are part of
Home Assistant backups. The app is stopped while a backup is taken, so the
SQLite database is consistent.

With PostgreSQL or an external MySQL, back up that database separately. The
MariaDB app's data is included in its own app backup.

## Versions

App versions are `<Forgejo version>-<build>`, e.g. `17.0.0-42`. The first part
is the Forgejo release inside; the build number goes up with every change to
the app. See the [changelog](CHANGELOG.md).
