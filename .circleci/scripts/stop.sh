StopAgent() {
    if [ "$UID" = "0" ]; then export SUDO=''; else export SUDO='sudo'; fi
    $SUDO service datadog-agent stop
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    StopAgent
fi