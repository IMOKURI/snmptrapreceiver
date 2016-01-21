# snmptrapreceiver

**[Work In Progress]** SNMP trap receiver  

[![Build Status](https://travis-ci.org/IMOKURI/snmptrapreceiver.svg?branch=master)](https://travis-ci.org/IMOKURI/snmptrapreceiver)

## Description

* Receive SNMP trap and logging to `./log/snmptrap.log`
* Logging format is `<Zoned Time>,<Hostname>,<SNMP Trap OID>,<Variable Bindings>`
  - SNMP Trap OID: This is SNMP v2 format. Therefore if you receive SNMP v1 trap, it converts to SNMP v2 format by [RFC2576 Section 3.1.](https://www.ietf.org/rfc/rfc2576.txt)
  - Variable Bindings: There are combination of OID and value

## Usage

```
Usage: snmptrapreceiver [-i IP] [-p PORT]

Available options:
  -h,--help                Show this help text
  -i IP                    IP address that is listened
  -p PORT                  PORT that is listened
```

## Motivation

This tool is inspired by [SNMPTT](http://snmptt.sourceforge.net/).  


