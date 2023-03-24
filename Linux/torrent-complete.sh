#!/bin/bash

# https://gist.github.com/paul-chambers/71ef48e40449ec73eef95430b9e4e6c7

# Helper script for deluge or qBittorrent bittorrent clients
# Intended to be run when the torrent download completes
#
# for qBittorrent, enable 'Run external program on torrent completion' under 'Downloads' in the options dialog.
# in the text field, enter:
#
#    <path to>/torrent-complete.sh "%K" "%N" "%D"
#
# This provides the same parameters to this script that deluge provides to 'torrent complete' scripts.
#
# The basic idea is to hardlink the files that the bittorrent client has just finished downloading to a second directory.
# This allows you to configure qBittorrent to automatically pause or delete torrents when they reach a given seed ratio,
# while also keeping a copy around for further processing.
#
# For example, SyncThing could be used to propagate new downloads to a remote machine to be processed further. When remote
# processing has finished, and the file is deleted/moved out of the remote downloads folder, the remote Syncthing will
# propagate a deletion back to the original Synchting (on the machine running this bittorrent client).
#
# This approach works equally well for rclone.
#
# The end result is that the lifetime of files involved both in the torrent client's seeding process and the 'transfer
# to somewhere else' process (e.g. via reclone or Syncthing) are decoupled, and can safely execute in parallel without
# needing to be aware of what the other is doing. And yet the net result is that the files will still be cleaned up
# automagically when both have finished their respective tasks.
#
# Paul Chambers, Copyright (c) 2019-2023.
#
# Made available under the Creative Commons 'BY' license
# https://creativecommons.org/licenses/by/4.0/
#

set -x

torrentID=$1
torrentName=$2
torrentPath=$3

#srcDir="${HOME}/seeding"
#destDir="${HOME}/downloads"
srcDir="/data/torrents/UnionFansub"
destDir="/data/torrents/Anime"

# either empty, or has a leading slash
label="${torrentPath#$srcDir}"

# note that srcPath may be a file, not necessarily a
# directory. In which case, the same is true for destPath.
srcPath="${torrentPath}/${torrentName}"
destPath="${destDir}${label}/${torrentName}"

echo "${torrentID} \"${torrentName}\" \"${torrentPath}\" ${label}" >> ~/logs/torrent-complete.log

# Non-rar files are always hardlinked to the destination.

# mkdir -p "${destPath}"
cp -vrl -t "${destDir}${label}" "${srcPath}"

# We may be given a file or a directory. If it's a directory, it may contain one or more rar files, in which case
# we unpack each one directly into the destination hierarchy.

#if [ -d "${destPath}" ]
#then
#    # multiple rar files may be found in subdirectories, so handle each one, preserving hierarchy
#    find "${destPath}" -name '*.rar' -print0 | while read -d $'\0' rarFile
#    do
#        # unrar does not delete the rar file(s) after it's finished extracting. But it does tell us
#        # on stdout which files it is parsing as it expands the archive. With a little sed magic,
#        # we parse out those filenames from stdout and remember them. If unrar completes without
#        # error, we then use that list to delete the file(s) that made up the rar archive.
#
#        rarFileList=$(mktemp)
#        path="$(dirname "${rarFile}")"
#        unrar x -idp -o+ "${rarFile}" "${path}" | \
#            sed -n -e "s/^Extracting from \(.*\.r[a0-9][r0-9]\)$/\1/ w ${rarFileList}" \
#         && xargs --no-run-if-empty --arg-file="${rarFileList}" rm \
#         && rm "${rarFileList}"
#    done
#fi

# We could unpack other archives here too (e.g. .zip files), but it's preferable to transfer archives
# to a remote machine in their compressed form, and decompress them there.

# remove any files we don't need from {destPath}, to avoid wasting bandwidth transferring them.
# this is a personal preference - adjust to taste

#find "${destPath}" -name 'NFO' -printf "%h\0" | xargs -0 --no-run-if-empty rm -r