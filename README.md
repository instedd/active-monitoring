# Active Monitoring

## Dockerized development

To get started checkout the project, then execute `./dev-setup.sh`

To run the app: `docker-compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To open a shell in a container: `docker exec -it active_monitoring_db_1 bash`, where `active_monitoring_db_1` is a container name. You can list containers with `docker ps`.

To start an Elixir console in your running Phoenix app container: `docker exec -it active_monitoring_app_1 iex -S mix`.

## Exposing your containers as *.activemonitoring.dev

You can use [dockerdev](https://github.com/waj/dockerdev) to access the web app at `app.activemonitoring.dev` and ngrok at `ngrok.activemonitoring.dev`.

Just follow the instructions at the README of dockerdev.

## Developing with local GUISSO & Verboice

The easiest path to using a local Verboice instance is to use a local GUISSO too. Start by running a local GUISSO via `docker-compose up` in that project - you should be able to browse http://web.guisso.dev/ then.

Register both ActiveMonitoring and Verboice there as new, trusted applications. Use `app.activemonitoring.dev` and `web.verboice.dev` as hostnames. Edit the `ActiveMonitoring` app and fill the `Redirect uris` field with the following URIs:

 - `http://app.activemonitoring.dev/oauth_callback`
 - `http://app.activemonitoring.dev/oauth_client/callback`
 - `http://app.activemonitoring.dev/session/oauth_callback`

Edit the Verboice GUISSO app and replace the `guisso.yml` from Verboice working directory. Then run Verboice.

Export ActiveMonitoring environment variables as follows:

| Variable                   | Content                                                                                        |
|----------------------------|------------------------------------------------------------------------------------------------|
| `GUISSO_CLIENT_ID`         | ActiveMonitoring's Client ID on GUISSO                                                         |
| `GUISSO_CLIENT_SECRET`     | ActiveMonitoring's Client Secret on GUISSO                                                     |
| `GUISSO_REDIRECT_URI`      | ActiveMonitoring `/oauth_callback`'s URL                                                       |
| `GUISSO_BASE_URL`          | GUISSO's URL to use for login                                                                  |
| `VERBOICE_BASE_URL`        | Verboice's URL                                                                                 |
| `VERBOICE_GUISSO_BASE_URL` | GUISSO's URL to use for authorizing Verboice resources (usually the same as `GUISSO_BASE_URL`) |
| `VERBOICE_CLIENT_ID`       | Verboice's Client ID on GUISSO                                                                 |
| `VERBOICE_CLIENT_SECRET`   | Verboice's Client Secret on GUISSO                                                             |
| `VERBOICE_APP_ID`          | Verboice's Hostname on GUISSO                                                                  |

## Coherence

### Upgrading

We're using Coherence to support registration, authorization, and other user management flows.
If you need to upgrade the version of Coherence that Ask uses, there are some steps that you need to mind.
Please check them out here: https://github.com/smpallen99/coherence#upgrading

### Coherence Mails

Coherence uses Swoosh as it's mailer lib. In development, we use Swoosh's local adapter, which
mounts a mini email client that displays sent emails at `{BASE_URL}/dev/mailbox`. That comes handy
to test flows which depend on email without having to send them in development.

## Learn more

* Phoenix
  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
