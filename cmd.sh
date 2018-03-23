#!/usr/bin/env bash

# change reset pin assignment if configured and not default
defaultResetPin=25
if [ -z "$PI_RESET_PIN" ]; then
  echo "PI_RESET_PIN env variable not set, reset pin assignment remains as-is (pin $defaultResetPin)"
else
  if [ "$PI_RESET_PIN" == $defaultResetPin ]; then
    echo "PI_RESET_PIN env variable is the same as the default pin assignment -> no changes"
  else
    echo "Re-assigning reset pin from $defaultResetPin to ${PI_RESET_PIN}"
    sed -i -e "s/SX1301_RESET_BCM_PIN=25/SX1301_RESET_BCM_PIN=${PI_RESET_PIN}/g" ./start.sh
  fi
fi

if [ -z "$IMST_LORA_LITE" ]; then
  echo "IMST_LORA_LITE env variable not set, not applying the SX1301 reset pin fix."
else
  echo "IMST_LORA_LITE env variable set. Applying the fix by commenting out the unexport SX1301 reset pin line."
  sed -i -e "s/echo\s\"\$SX1301_RESET_BCM_PIN\"\s\s>\s\/sys\/class\/gpio\/unexport/#&/g" ./start.sh
fi

defaultRegion="EU"
if [ -z "$GATEWAY_REGION" ]; then
  echo "GATEWAY_REGION env variable not set, using default region '$defaultRegion')"
else
  if [ "$GATEWAY_REGION" == $defaultRegion ]; then
    echo "GATEWAY_REGION env variable is the same as the default region -> no changes"
  else
    echo "Setting gateway region to '$GATEWAY_REGION'"
    region=$(echo "${GATEWAY_REGION}" | tr "[:upper:]" "[:lower:]")
    sed -i -e "s/router.eu.thethings/router.$region.thethings/g" ./local_conf_template.json
  fi
fi

# inject the values provided by the user into the template
envsubst < local_conf_template.json > local_conf.json

# start script from https://github.com/ttn-zh/ic880a-gateway
./start.sh
