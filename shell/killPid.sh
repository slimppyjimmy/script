#!/bin/bash
kill -9 $(ps -ef | grep -E 'distnoted|TextInputMen' | grep -v grep | awk '{print$2}' )
