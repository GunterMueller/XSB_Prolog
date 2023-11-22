#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running socket_tests/test.sh                     ---"
echo "-------------------------------------------------------"

XEMU=$1
options=$2

    # XEMU and options must be together in quotes
# Test stream I/O
../gentest.sh "$XEMU $options" socket_stream "test."
# Test message I/O and timeouts
../gentest.sh "$XEMU $options" socket_msg "test."
# Test stream-oriented, unbuffered socket_put/socket_get0.
../gentest.sh "$XEMU $options" socket_put "test."
