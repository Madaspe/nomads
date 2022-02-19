job gitea {
  datacenters = [ru-central-1]
  priority    = 50

  group git {
    network {
      port ssh_pass {
        to = 22
        static = 2222
      }
      port http {
        to = 3000
        static = 3000
      }
      port db {
        to = 5432
      }
    }

    volume pg-data {
        type      = host
        source    = pg-data
        read_only = false
    }
    
    task gitea {
    
      driver = podman

     config {
        image = gitea/gitea:1.16.0
        ports = [http]
      }

      env {
        APP_NAME   = Gitea: Git with a cup of tea
        ROOT_URL   = http://localhost
        DB_TYPE    = postgres
        DB_HOST    = 
        DB_NAME    = gitea
        DB_USER    = gitea
        DB_PASSWD  = gitea
        USER_UID   = 1000
        USER_GID   = 1000
      }
    }

    task db {
        service {
            name = db
            port = db

            check {
                type     = tcp
                port     = db
                interval = 10s
                timeout  = 2s
            }
        }

        driver = podman

        env {
            POSTGRES_PASSWORD=gitea
            POSTGRES_USER=gitea
            POSTGRES_DB=gitea
            PGDATA=/var/lib/postgresql/data/pgdata
        }

        volume_mount {
            volume      = pg-data
            destination = /var/lib/postgresql/data
        }

        config {
            image = postgres
            ports = [db]
        }

        resources {
            cpu    = 500
            memory = 256
        }
    }
  }
}
