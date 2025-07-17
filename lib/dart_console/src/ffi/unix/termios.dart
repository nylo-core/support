import 'dart:ffi';

// INPUT FLAGS
const int ignbrk = 0x00000001; // ignore BREAK condition
const int brkint = 0x00000002; // map BREAK to SIGINTR
const int ignpar = 0x00000004; // ignore (discard) parity errors
const int parmrk = 0x00000008; // mark parity and framing errors
const int inpck = 0x00000010; // enable checking of parity errors
const int istrip = 0x00000020; // strip 8th bit off chars
const int inlcr = 0x00000040; // map NL into CR
const int igncr = 0x00000080; // ignore CR
const int icrnl = 0x00000100; // map CR to NL (ala CRMOD)
const int ixon = 0x00000200; // enable output flow control
const int ixoff = 0x00000400; // enable input flow control
const int ixany = 0x00000800; // any char will restart after stop
const int imaxbel = 0x00002000; // ring bell on input queue full
const int iutf8 = 0x00004000; // maintain state for UTF-8 VERASE
// OUTPUT flags
const int opost = 0x00000001; // enable following output processing
const int onlcr = 0x00000002; // map NL to CR-NL (ala CRMOD)
const int oxtabs = 0x00000004; // expand tabs to spaces
const int onoeot = 0x00000008; // discard EOT's (^D) on output)
// CONTROL flags
const int cignore = 0x00000001; // ignore control flags
const int csize = 0x00000300; // character size mask
const int cs5 = 0x00000000; // 5 bits (pseudo)
const int cs6 = 0x00000100; // 6 bits
const int cs7 = 0x00000200; // 7 bits
const int cs8 = 0x00000300; // 8 bits
// LOCAL flags
const int echoke = 0x00000001; // visual erase for line kill
const int echoe = 0x00000002; // visually erase chars
const int echok = 0x00000004; // echo NL after line kill
const int echo = 0x00000008; // enable echoing
const int echonl = 0x00000010; // echo NL even if ECHO is off
const int echoprt = 0x00000020; // visual erase mode for hardcopy
const int echoctl = 0x00000040; // echo control chars as ^(Char)
const int isig = 0x00000080; // enable signals INTR, QUIT, [D]SUSP
const int icanon = 0x00000100; // canonicalize input lines
const int altwerase = 0x00000200; // use alternate WERASE algorithm
const int iexten = 0x00000400; // enable DISCARD and LNEXT
const int extproc = 0x00000800; // external processing
const int tostop = 0x00400000; // stop background jobs from output
const int flusho = 0x00800000; // output being flushed (state)
const int nokerninfo = 0x02000000; // no kernel output from VSTATUS
const int pendin = 0x20000000; // retype pending input (state)
const int noflsh = 0x80000000; // don't flush after interrupt
const int tcsanow = 0; // make change immediate
const int tcsadrain = 1; // drain output, then change
const int tcsaflush = 2; // drain output, flush input
const int vmin = 16; // minimum number of characters to receive
const int vtime = 17; // time in 1/10s before returning

// typedef unsigned long   tcflag_t;
typedef tcflag_t = UnsignedLong;

// typedef unsigned char   cc_t;
typedef cc_t = UnsignedChar;

// typedef unsigned long   speed_t;
typedef speed_t = UnsignedLong;

// #define NCCS            20
// ignore: constant_identifier_names
const _NCCS = 20;

// struct termios {
// 	tcflag_t        c_iflag;        /* input flags */
// 	tcflag_t        c_oflag;        /* output flags */
// 	tcflag_t        c_cflag;        /* control flags */
// 	tcflag_t        c_lflag;        /* local flags */
// 	cc_t            c_cc[NCCS];     /* control chars */
// 	speed_t         c_ispeed;       /* input speed */
// 	speed_t         c_ospeed;       /* output speed */
// };
base class TermIOS extends Struct {
  @tcflag_t()
  external int c_iflag;
  @tcflag_t()
  external int c_oflag;
  @tcflag_t()
  external int c_cflag;
  @tcflag_t()
  external int c_lflag;

  @Array(_NCCS)
  external Array<cc_t> c_cc;

  @speed_t()
  external int c_ispeed;
  @speed_t()
  external int c_ospeed;
}

// int tcgetattr(int, struct termios *);
typedef TCGetAttrNative = Int32 Function(
    Int32 fildes, Pointer<TermIOS> termios);
typedef TCGetAttrDart = int Function(int fildes, Pointer<TermIOS> termios);

// int tcsetattr(int, int, const struct termios *);
typedef TCSetAttrNative = Int32 Function(
    Int32 fildes, Int32 optional_actions, Pointer<TermIOS> termios);
typedef TCSetAttrDart = int Function(
    int fildes, int optional_actions, Pointer<TermIOS> termios);
