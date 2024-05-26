## A dashboard for applying and managing Patchwork's features in Mastodon instance

## Features

### - Enable or disable content filtering on timelines using hashtags and keywords

### - Enable or disable filtering of Threads/Bluesky content on timelines

## Setup guide

Before running this application, ensure that a Mastodon instance is set up from source and running properly:
- [A Mastodon server set up from source](https://docs.joinmastodon.org/admin/install/)

Clone this repository in your server:

```git
git clone git@github.com:patchwork-hub/patchwork_dashboard.git
```

Create .env file by coping .env.sample file:
```bash
$ cp .env.sample .env
```

Modify following environment variables:
```
RAILS_ENV=production

# Redis
# Connect with your mastodon instance's redis
REDIS_HOST=localhost
REDIS_PORT=6379

# PostgreSQL 
# Connect with your mastodon instance's database
DB_HOST=your_db_host
DB_NAME=your_mastodon_instance_db
DB_USER=your_db_username
DB_PASS=your_db_password
DB_PORT=5432
```

Run below docker commands to build the docker image and run the containers:
```bash
$ docker-compose build
$ docker-compose up -d
```

Get inside the docker container to feed necessary data to database:
```bash
$ docker exec -it patchwork-dashboard bash
```

Once your are inside the docker container, run below command to feed the data:
```bash
$ RAILS_ENV=production bundle exec rake db:seed
```

The container is open to port **3001** and you can access the application with ServerIP:3001.

To login to the dashboard, use your Mastodon instance's admin account.

As next, you can move on to setting up the **content-filters** gem in your Mastodon server:
- [Install Patchwork's content_filters gem in your Mastodon instance](https://github.com/patchwork-hub/content_filters/blob/main/README.md)

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
