# Active Monitoring

## Dockerized development

To get started checkout the project, then execute `./dev-setup.sh`

To run the app: `docker-compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To open a shell in a container: `docker exec -it active_monitoring_db_1 bash`, where `active_monitoring_db_1` is a container name. You can list containers with `docker ps`.

To start an Elixir console in your running Phoenix app container: `docker exec -it active_monitoring_app_1 iex -S mix`.

## Exposing your containers as *.active-monitoring.dev

You can use [dockerdev](https://github.com/waj/dockerdev) to access the web app at `app.active-monitoring.dev` and ngrok at `ngrok.active-monitoring.dev`.

Just follow the instructions at the README of dockerdev.

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
