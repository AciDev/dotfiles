function _aws_sso_token -d "Print a valid cached SSO access token + region for an sso-session (tab-separated)"
    set -l session $argv[1]
    test -z "$session"; and set session default

    python3 -c '
import configparser, os, sys, json, glob
from datetime import datetime, timezone

session = sys.argv[1]
cfg = configparser.ConfigParser()
cfg.read(os.path.expanduser("~/.aws/config"))
sec = "sso-session " + session
if sec not in cfg:
    sys.exit(2)
start = cfg[sec].get("sso_start_url")
region = cfg[sec].get("sso_region", "")

for f in glob.glob(os.path.expanduser("~/.aws/sso/cache/*.json")):
    try:
        d = json.load(open(f))
    except Exception:
        continue
    if d.get("startUrl") != start or "accessToken" not in d:
        continue
    exp = d.get("expiresAt", "")
    try:
        e = datetime.fromisoformat(exp.replace("Z", "+00:00"))
        if e <= datetime.now(timezone.utc):
            continue
    except Exception:
        pass
    print(d["accessToken"] + "\t" + region)
    sys.exit(0)
sys.exit(1)
' $session
end
