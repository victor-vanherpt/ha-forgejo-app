# Home Assistant App: Forgejo

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[Forgejo](https://forgejo.org) is a self-hosted lightweight software forge:
Git hosting, code review, issues, packages and CI, all in one place.

This app runs Forgejo on your Home Assistant server, with:

- SQLite out of the box, or PostgreSQL / MySQL (including the MariaDB app)
- Git over HTTP and over SSH (Forgejo's built-in SSH server)
- `app.ini` editable from Home Assistant's app configuration folder
- Options that map one to one to Forgejo's `app.ini` settings

See the **Documentation** tab for setup.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

## Credits

The Forgejo logo (`icon.png`, `logo.png`) was created by
[Caesar Schinas](https://caesarschinas.com/) and is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). The images here
are PNG renderings of the
[original SVG](https://codeberg.org/forgejo/governance/src/branch/main/branding),
and are licensed under CC BY-SA 4.0 as well, not under this repository's MIT
license. This app is not affiliated with the Forgejo project.
