# SPDX-FileCopyrightText: 2023-present pfSDK contributors
#
# SPDX-License-Identifier: GPL-3.0-or-later

import subprocess
import sys
import os

from typing import List


# -- Classes
class pfScriptUtils:
    @classmethod
    def shellCommand(cls, command_and_args: List[str], from_dir: str = '.', silent_mode=False, env=None, shell_mode=False):
        try:
            merged_env = None
            if env is not None:
                merged_env = dict()
                merged_env.update(os.environ)
                merged_env.update(env)

            # print(' '.join(command_and_args))
            process = subprocess.Popen(command_and_args, cwd=from_dir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=merged_env, shell=shell_mode)
            if silent_mode is False:
                for line in iter(process.stdout.readline, b''):
                    sys.stdout.write(str(line)[2:-1].replace('\\n', '\n'))

            if process.wait() != 0:
                raise RuntimeError('Error running shell command.')

        except RuntimeError:
            raise
        except SyntaxError:
            raise
        except Exception as e:
            raise RuntimeError('Error running shell command: ' + str(e))

    @classmethod
    def commandExists(cls, command: str) -> bool:
        try:
            pfScriptUtils.shellCommand(['which', command], silent_mode=True)
        except Exception:
            return False

        return True

    @classmethod
    def requireCommand(cls, command: str):
        if not pfScriptUtils.commandExists(command):
            raise RuntimeError('❌ Cannot find command \'' + command + '\'.')
