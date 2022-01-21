
# port_based_on_test_name gives a stable port number in the 49152-65535 range
# derived from a hash of the test name. This is required because our test data
# includes local registry URLs which include the port number, so we can't have
# it changing randomly as then the test data would be impossible to keep up to date.
getport_stablehash() {
	TEST_HASH="$((16#$(cat - | sha1sum | cut -d' ' -f1)))"
	MIN_PORT=49152
	MAX_PORT=65535
	RANGE=$(( MAX_PORT - MIN_PORT ))
	ADD=$(( TEST_HASH % RANGE ))
	echo "$(( MIN_PORT + ADD ))"
}
