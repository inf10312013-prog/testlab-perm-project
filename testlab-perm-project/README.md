# TestLab Report Output Manager

A reproducible permission model for shared test stations, plus a service/timer template to schedule report generation.

## Background (Problem)
In a shared test station, logs/reports are generated continuously. Typical issues:
- Different owners/groups prevent teammates from appending/editing the same report/log.
- Permissions drift over time; people resort to `sudo`, reducing traceability and maintainability.
- Turning report generation into a scheduled workflow (service/timer) requires stable output permissions.

## Solution
This project standardizes report/log output with:
- Shared group: `testlab`
- Shared directories: `/srv/testlab/logs` and `/srv/testlab/reports`
- **setgid** on directories so new files inherit `group=testlab`
- **default ACL** so new files/dirs inherit group-writable permissions reliably
- A demo report generator script and systemd service/timer templates (for real Ubuntu hosts)

## Project Structure
- `scripts/setup_testlab.sh` — one-click setup (group/users/dirs/setgid/ACL)
- `scripts/verify.sh` — one-click verification (permissions/ACL + multi-user append test)
- `scripts/run_report.sh` — generate timestamped report into `/srv/testlab/reports/`
- `systemd/testlab-report.service` — oneshot service template
- `systemd/testlab-report.timer` — schedule template

## Quick Demo (Docker)
1) Setup:
```bash
bash scripts/setup_testlab.sh

bash scripts/verify.sh

su - runner -c /work/scripts/run_report.sh
ls -lt /srv/testlab/reports | head
tail -n 5 /srv/testlab/logs/run.log

sudo apt-get update
sudo apt-get install -y acl

# Run once: setup users/group/shared dirs
sudo bash scripts/setup_testlab.sh

# Install report script
sudo cp scripts/run_report.sh /usr/local/bin/testlab_run_report.sh
sudo chmod +x /usr/local/bin/testlab_run_report.sh

# Install systemd units
sudo cp systemd/testlab-report.service /etc/systemd/system/
sudo cp systemd/testlab-report.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now testlab-report.timer

# Validate
systemctl list-timers | grep testlab
journalctl -u testlab-report.service -n 50 --no-pager

cat > /work/README.md <<'EOF'
# TestLab Report Output Manager

A reproducible permission model for shared test stations, plus a service/timer template to schedule report generation.

## Background
In a shared test station, logs/reports are generated continuously. Typical issues:
- Different owners/groups prevent teammates from appending/editing the same report/log.
- Permissions drift over time; people resort to sudo, reducing traceability and maintainability.
- Scheduling report generation (service/timer) requires stable output permissions.

## Solution
- Shared group: testlab
- Shared directories: /srv/testlab/logs and /srv/testlab/reports
- setgid on directories so new files inherit group=testlab
- default ACL so new files/dirs inherit group-writable permissions reliably
- Demo report generator script and systemd service/timer templates (for real Ubuntu hosts)

## Project Structure
- scripts/setup_testlab.sh  : one-click setup (group/users/dirs/setgid/ACL)
- scripts/verify.sh         : one-click verification (permissions/ACL + multi-user append test)
- scripts/run_report.sh     : generate timestamped report into /srv/testlab/reports/
- systemd/testlab-report.service : oneshot service template
- systemd/testlab-report.timer   : schedule template

## Quick Demo (Docker)
1) Setup:
   bash scripts/setup_testlab.sh

2) Verify shared write (runner creates, analyst appends):
   bash scripts/verify.sh

3) Generate a timestamped report:
   su - runner -c /work/scripts/run_report.sh
   ls -lt /srv/testlab/reports | head
   tail -n 5 /srv/testlab/logs/run.log

## Deploy on a real Ubuntu test machine
Note: Many Docker containers do not run systemd. Use the steps below on a real Ubuntu host.

sudo apt-get update
sudo apt-get install -y acl

# Run once: setup users/group/shared dirs
sudo bash scripts/setup_testlab.sh

# Install report script
sudo cp scripts/run_report.sh /usr/local/bin/testlab_run_report.sh
sudo chmod +x /usr/local/bin/testlab_run_report.sh

# Install systemd units
sudo cp systemd/testlab-report.service /etc/systemd/system/
sudo cp systemd/testlab-report.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now testlab-report.timer

# Validate
systemctl list-timers | grep testlab
journalctl -u testlab-report.service -n 50 --no-pager
