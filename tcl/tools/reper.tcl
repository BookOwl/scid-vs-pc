### reper.tcl:
### Repertoire editor functions for Scid.
### Copyright (C) 2001-2002 Shane Hudson.

# Images and bitmaps used in heirarchical repertoire view.
# I found the open and closed folder images used at the sourceforge.net
# website, but i hope to find or create nicer-looking ones...

image create photo ::rep::_closedgroup -data {
  R0lGODdhDwANAIQAAP7+/AICBMa6la6ehJaJda6ihPbu6ubcwNbGtN7V2c7Dp97Opc66m8a1
  lLaniu7q2Xp0cHJuW+7m1LaulKaYfL6zl25mWJ6ObYJ5a1pVTQAAAAAAAAAAAAAAAAAAAAAA
  ACwAAAAADwANAAAFYSAgjmQ5BmhgkoEwuOoaDARdEGkqBsbR/wZE4qBQBQ6CBUO5EDQcAhwg
  8GgynVAHxHhYLgWCbCFilDAbYUFhQiFPu4tK2uGgUCzlBRpaqF8IeG8QBBgUGIQRFhYZMTmO
  OiEAOw==
}

#image create photo ::rep::_oldgroup -data {
#R0lGODdhEAAPAMIAAP////j4+Hh4eLi4uPj4AAAAAAAAAAAAACwAAAAAEAAPAAADPAi63BBB
#SAlrfWIQPYS92SZ2EwUIjiMUJzC+2tpy8CajNX0DdG+zOJ8OyMv9WsYYsMQssQKFqHQ6TVkV
#CQA7
#}

image create photo ::rep::_opengroup -data {
  R0lGODdhDwANAKUAAP7+/O7u7M7OzDo6NN7e3PLy5J6enNbW1K6urH5+fDo2LIZ+bK6qnJaW
  lGpqbFZSRF5eXG5ubG5mVLaunNLOxObm4HpyZGJiXA4ODBoWFJaOfHZuXI6GdObi3OLi5EpG
  RJqOfMrKzNrWzPb27Pr69CIiHH52ZJqSfBoaFFpWT4J6ZN7azCoqLGZeVKqqrLq2pO7q5IaG
  hKKahL6+vFZWVGpmVD4+PJKKdAYGBAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAADwANAAAG
  kkCAcBgQCAYDwrBgOAAQhoRCsWA0BAaD4wGJQB6SCYVSsVwemIxmseF0PAUA5ONYgDIhhUY0
  IhESJSYcICcnKAQpKisADSwtIBonGpMZAC4fLyMoJyCdkJMoAB0RGzAZhJKchJUAMS0yKJOy
  HA8lM0M0JhmFnDU2BkNCBimnIDUPN8HBLCgWCgnAykMHODQCAdJBADs=
}

image create photo ::rep::_tick -data {
  R0lGODdhEAAQAKEAAP///wAAAFFR+wAAACwAAAAAEAAQAAACMISPacHtvpQKUSIKsBQiV8V1
  mIaEFWmYJ8Cl7TGynQpH4XtV9/ThuWepZR5ERtBSAAA7
}

image create photo ::rep::_cross -data {
  R0lGODdhEAAQAKEAAP///wAAAPoTQAAAACwAAAAAEAAQAAACL4SPacHtvpQKUSIKsFA7V9EZ
  YIUBoxliJXqSSeseIKzKXVujyJlbse/JPIYMoKQAADs=
}

image create photo ::rep::_tb_group -data {
  R0lGODlhEQARAIQAANnZ2QICBMa6la6ehJaJda6ihPbu6ubcwNbGtN7V2c7Dp97Opc66m8a1
  lLaniqmpqe7q2Xp0cHJuW+7m1LaulKaYfL6zl25mWJ6ObYJ5a1pVTScznicznicznicznicz
  niwAAAAAEQARAAAFdiAgjmRpnigQrEE6BsIQt2kwEHdBsCwZGAeg0IBIHBQ01UGwYDQXgoZD
  sHuIAhDoMzp1RAJWpdMpEHQLEvB18myYBQVKJR0OHJyWt8NRqVzUKmxuUwV8GAR/dQcRBBkV
  GY0SFxcagCo8mCsPYSKbnp+eLqKjIyEAOw==
}

image create photo ::rep::_tb_include -data {
  R0lGODlhEQARAKEAAP///9nZ2QAAAFFR+ywAAAAAEQARAAACOYyPecLtvoCcVIpY8zUizzEA
  W9B5YDiW1WlhFNtyACjBMTmH9t2ddJWq7XifkMbl4T2WDIXzCVUUAAA7
}

image create photo ::rep::_tb_exclude -data {
  R0lGODlhEQARAKEAANnZ2QAAAP////oTQCwAAAAAEQARAAACOoSPecHtvoScVIZY8zVBjvwJ
  G9AJQ+iFY2mG57RS5wtjE11z8kzF6W/B4FpBXabiO+ZIjyZDAY1KFQUAOw==
}

set maskdata "#define solid_width 9\n#define solid_height 9"
append maskdata {
  static unsigned char solid_bits[] = {
    0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01,
    0xff, 0x01, 0xff, 0x01, 0xff, 0x01
  };
}

set data "#define open_width 9\n#define open_height 9"
append data {
  static unsigned char open_bits[] = {
    0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x7d, 0x01, 0x01, 0x01,
    0x01, 0x01, 0x01, 0x01, 0xff, 0x01
  };
}

image create bitmap ::rep::_shown -data $data -maskdata $maskdata \
    -foreground black 

set data "#define closed_width 9\n#define closed_height 9"
append data {
  static unsigned char closed_bits[] = {
    0xff, 0x01, 0x01, 0x01, 0x11, 0x01, 0x11, 0x01, 0x7d, 0x01, 0x11, 0x01,
    0x11, 0x01, 0x01, 0x01, 0xff, 0x01
  };
}

image create bitmap ::rep::_hidden -data $data -maskdata $maskdata \
    -foreground black 

###
### End of file: reper.tcl
###
