# Outlook Spam Automator

## Principle

### Basics

OSA asks you to choose your junk folder on first configuration. After the folder is selected, the `scan-junk` command
allows you to scan the folder to report and delete any unwanted spam. It's important to chose the actual junk folder
so your Outlook spam filters does not get broken. However, OSA will work with any folder. The processing for each email
uses the following rules:

1. If the email is flagged, the email is reported to Spamcop, then deleted and the sender is blacklisted.
2. If the email's sender is blacklisted, the email is reported to Spamcop, then deleted.
3. Otherwise, the email is left untouched. 

*OSA will not touch any folder beside the folder you've chosen.*

*It's the user's responsibility to move junk mails to the junk folder and flag them to build up the blacklist.*

### The blacklist

Blacklisting is performed using the main domain name of the sender, excluding subdomains. For example, an email sent from
`spammer@spam.example.com`, will blacklist any sender from `example.com`, so `legit-person@not-spam.example.com` will also
be blacklisted. However, to prevent millions of users to go blacklisted because of a single user's spam, OSA includes a
list of free email providers (which includes domains like gmail.com, outlook.com among others). If the sender uses a free
email provider, the full address is blacklisted.

OSA also supports Domain Name System Blacklist. In fact it comes bundled with 3 DNSBL:
1. [Spamcop Blocking List](https://www.spamcop.net/fom-serve/cache/297.html)
2. [Spamhaus Block List](https://www.spamhaus.org/sbl)
3. [Passive Spam Block List](https://psbl.org)

You can remove these or add more blacklists, from the database, after you configure OSA.

## Installation

You can install OSA from RubyGems:

```sh
gem install osa
```

Or use the Docker image:

```sh
docker pull moray95/osa:{version}
```

## Configuring the database

OSA uses a simple sqlite database to store your configurations and blacklist. The database is configured by default at
the current working directory. This means that after a first setup, if you run OSA from a different directory, you will
start from a blank configuration and blacklist. If you need to run from different directories, you can specify the database
file with the `DATABASE` environment variable.

## Usage

Setup your account and settings:

The setup process will authenticate you with Outlook and ask you to select your folders. If you want to create
a new folder, make sure you do it before you run the script.

```sh
osa setup
```

Each time you run this command, your previous configuration will be erased, except for your blacklist.

Process your junk folder:

```sh
osa scan-junk
```

OSA also provides you a nice administration dashboard you. You can access the dashboard by running

```sh
osa dashboard
```

You are now able to access the dashboard on `http://localhost:8080`. You can also change the port of the server by
providing the `SERVER_PORT` environment variable.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moray95/osa.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
