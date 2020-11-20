# Outlook Spam Automator

## Principle

### Basics

OSA uses asks you to choose two folders one "junk" folder and one "report" folder. Even though you can choose any folder
for both, it's recommend to choose the default junk folder as the junk folder and create a custom folder for as the report
folder.

These two folders will be used the following way:
- When the report folder is scanned, all emails are reported to [Spamcop](https://spamcop.net), deleted and the senders blacklisted.
- When the junk folder is scanned, all emails from the blacklist are reported to [Spamcop](https://spamcop.net) and deleted.

*OSA will not touch any folder beside these two.*

*It's the user's responsibility to move junk mails to the report folder to build up the blacklist.*

### The blacklist

Blacklisting is performed using the main domain name of the sender, excluding subdomains. For example, an email sent from
`spammer@spam.example.com`, will blacklist any sender from `example.com`, so `legit-person@not-spam.example.com` will also
be blacklisted. However, to prevent millions of users to go blacklisted because of a single user's spam, OSA includes a
list of free email providers (which includes domains like gmail.com, outlook.com among others). If the sender uses a free
email provider, the full address is blacklisted.

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

Process your report folder:

```sh
osa scan-report
```

Process your junk folder:

```sh
osa scan-junk
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moray95/osa.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
