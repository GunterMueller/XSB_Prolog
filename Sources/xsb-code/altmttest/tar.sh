
\rm -f mttests.tar.gz

\rm -f */*.xwam
\rm -f */*/*.xwam
\rm -f */*/*.xwam

tar -cvf mttests.tar .
gzip mttests.tar
