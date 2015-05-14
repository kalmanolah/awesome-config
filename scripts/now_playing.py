#!/usr/bin/env python3
"""
This script prints some info about the currently playing song, in a pretty way.

@author Kalman Olah
"""

import cgi
import dbus
import shlex
import socket
import subprocess
import sys
import urllib


players = [
    'spotify',
    'ncmpcpp'
]


play_states = {
    'play': 'PLAYING',
    'pause': 'PAUSED',
    'stop': 'STOPPED',
    'Playing': 'PLAYING',
    'Paused': 'PAUSED',
    'Stopped': 'STOPPED'
}


def format_data(data):
    """Format song data to make it all pretty."""
    if not data:
        return

    # Start by truncating values that are too long
    max_len = 30
    for key in data:
        if type(data[key]) is not str:
            continue

        if data[key] and len(data[key]) > max_len:
            data[key] = data[key][:(max_len - 3)] + "..."

    status_str = ('[%s] ' % data['status']) if data['status'] != 'PLAYING' \
        else ''
    album_str = (' (%s)' % data['album']) if data['album'] else ''
    artist_str = ('%s ~ ' % data['artist']) if data['artist'] else ''
    title_str = data['title']

    formatted = status_str + artist_str + title_str + album_str

    if "--ascii" in sys.argv:
        formatted = formatted.encode("ascii", "ignore")

    if "--url-encode" in sys.argv:
        formatted = urllib.quote_plus(formatted)

    if "--html-safe" in sys.argv:
        formatted = cgi.escape(formatted)

    # if "--utf-8" in sys.argv:
    #    formatted = formatted.encode('utf8')

    return formatted


def get_playing(player):
    """Fetch and return track info for a player."""
    data = {
        'title': None,
        'artist': None,
        'album': None,
        'status': None
    }

    if player == 'spotify':
        try:
            bus = dbus.Bus(dbus.Bus.TYPE_SESSION)
            bus = bus.get_object('com.spotify.qt', '/')
            metadata = bus.GetMetadata()
            status = bus.Get('org.freedesktop.MediaPlayer2', 'PlaybackStatus')

            data['title'] = metadata['xesam:title']
            data['artist'] = metadata['xesam:artist'][0]
            data['album'] = metadata['xesam:album']
            data['status'] = play_states.get(status)
        except dbus.exceptions.DBusException:
            pass

    elif player == 'ncmpcpp':
        p = subprocess.Popen(
            shlex.split('ncmpcpp --now-playing "%t|D|%a|D|%b"'),
            stdout=subprocess.PIPE)

        metadata, err = p.communicate()
        if not metadata:
            return data

        metadata = metadata.decode().rstrip().split('|D|')

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('localhost', 6600))

        sock.recv(1024)
        sock.send('status\n'.encode('utf8'))

        res = sock.recv(1024)
        sock.close()

        status = []
        for v in res.decode().rstrip().split('\n'):
            vs = v.split(': ', 1)
            if len(vs) > 1:
                status.append(v.split(': ', 1))
        status = dict(status)['state']
        status = play_states.get(status)

        data['title'] = metadata[0]
        data['artist'] = metadata[1]
        data['album'] = metadata[2]
        data['status'] = status

    return data


if __name__ == '__main__':
    """Standard import guard."""
    data = None
    for p in players:
        tmp = get_playing(p)

        if tmp['title']:
            data = tmp

            if data['status'] == 'PLAYING':
                break

    if data:
        print(format_data(data))
