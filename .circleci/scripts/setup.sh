
Install() {
    PARAM_DD_API_KEY=$(eval echo "\$$PARAM_DD_API_KEY")

    if [[ -n "${DD_SITE}" ]]; then
        PARAM_DD_SITE=${DD_SITE}
    fi

    DD_API_KEY=${PARAM_DD_API_KEY} DD_AGENT_MAJOR_VERSION=${PARAM_DD_AGENT_MAJOR_VERSION} DD_SITE=${PARAM_DD_SITE} \
        DD_HOSTNAME="none" DD_INSTALL_ONLY="true" DD_APM_ENABLED="true" \
        bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

    if [ "$UID" = "0" ]; then export SUDO=''; else export SUDO='sudo'; fi
    $SUDO find /etc/datadog-agent/conf.d/ -iname "*.yaml.default" -delete
    $SUDO service datadog-agent start

    set +e
    attempts=0

    until [[ $attempts -eq 10 ]] || $SUDO datadog-agent health; do
        attempts=$((attempts+1))
        sleep_time=$(( attempts*5 < 30 ? attempts*5 : 30 ))
        echo "Waiting for agent to start up sleeping for ${sleep_time} seconds"
        sleep $sleep_time
    done

    if [[ $attempts -eq 10 ]]; then
        echo "Could not start the agent"
        exit 1
    else
        echo "Agent is ready"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    Install
fi