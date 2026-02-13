# Monitor AS
This project is a simple script in bash designed to monitor the prefixes announced by an ASN, using the RIPE database and its collectors.

It's simple, basic, and it works. Nothing more.

It is currently set up to notify changes via Telegram bot, but feel free to modify it to suit your alert system.


## Usage

```bash
git clone https://github.com/410g0n3/monitor_asn.git
# create log file first
sudo touch /var/log/monitor_asn.log
sudo chown user:user /var/log/monitor_asn.log

crontab -e

0 * * * * /bin/bash /user/path/monitor_asn.sh >> /var/log/monitor_asn.log
```
