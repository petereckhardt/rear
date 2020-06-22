# 470_safe_filesystems.sh
#
MANUAL_INC=$(echo "${MANUAL_INCLUDE}" | tr '[:upper:]' '[:lower:]')
>$VAR_DIR/recovery/nsr_paths
if [ ! "${BACKUP_ONLY_INCLUDE}x" = "x" ] && [ "${MANUAL_INC}" = "yes" ]
then
   #
   # only include filesystems which are backed up (savefs output) and which are
   # member of BACKUP_ONLY_INCLUDE
   # using loops to keep things simple, there are only a few entries
   #
   BACKED_UP=$(savefs -p -s $NSRSERVER 2>&1 | awk -F '(=|,)' '/path/ { printf ("%s ", $2) }')
   for fs in "${BACKUP_ONLY_INCLUDE[@]}"
   do
      for backed in ${BACKED_UP}
      do
        if [ "${fs}" = "${backed}" ]
        then
           echo ${fs} >> $VAR_DIR/recovery/nsr_paths
        fi
      done
   done
else
   # use savefs to retrieve the filesystems to recover
   savefs -p -s $NSRSERVER 2>&1 | awk -F '(=|,)' '/path/ { printf ("%s ", $2) }' > $VAR_DIR/recovery/nsr_paths
fi

[[ ! -s $VAR_DIR/recovery/nsr_paths ]] && Error "The savefs command could not retrieve the \"save sets\" from this client"

LogPrint "EMC Networker will recover these filesystems: $( cat $VAR_DIR/recovery/nsr_paths )"
