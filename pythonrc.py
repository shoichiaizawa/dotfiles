# File:   pythonrc.py
# Author: Shoichi Aizawa <shoichiaizawa@gmail.com>
# Source: https://github.com/shoichiaizawa/dotfiles/tree/master/pythonrc.py

try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")
