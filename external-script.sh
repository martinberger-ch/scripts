#!/bin/bash

case "$1" in
        pre)
sqlplus MY-CDB-CONNECT-STRING <<  EOF
SPOOL external_script_hc.log
SELECT SYSDATE FROM DUAL;
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
SELECT max(snap_id) FROM dba_hist_snapshot;

EXIT
EOF
;;
        post)
sqlplus MY-CDB-CONNECT-STRING <<  EOF
SPOOL external_script_hc.log
SELECT SYSDATE FROM DUAL;
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
SELECT max(snap_id) FROM dba_hist_snapshot;

EXIT
EOF
;;

        end) : ;;
esac

exit 0
