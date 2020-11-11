# infophone
get phone number information from numverify dot com

## Help

`perl infophone.pl -h`
or
`perl infophone.pl --help`

```
perl infophone.pl [-hinot] [long options...] <some-arg>

	-n STR --number STR  Phone number ex: +33699999999
	-i STR --input STR   File containing the numbers. One number per line.

	-o STR --output STR  Output file. STDOUT if omitted
	-t STR --type STR    output format (json,yaml) default: YAML

	-h --help            Affiche cette aide
```
