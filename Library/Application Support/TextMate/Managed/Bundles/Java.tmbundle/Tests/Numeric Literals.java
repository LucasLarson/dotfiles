// Integer

foo = 0;
foo = 123;
foo = 123_456_789;
foo = 123____456;
foo = 0L;
foo = 123L;


// Floating-Point

foo = 42.00;
foo = 0.5;
foo = .5;
foo = 42f;
foo = 3.59e0;
foo = 3.59e-1701D;


// Hexadecimal

foo = 0x48454c5021;
foo = 0x4927_4d;
foo = 0x54_524150504544;
foo = 0x494E;
foo = 0x48455245L;


// Octal

foo = 3301_8;
foo = 3301_8L;


// Binary

foo = 0b1;
foo = 0b1;
foo = 0b10;
foo = 0b11;
foo = 0b101;
foo = 0b0001;
foo = 0b1101;


// Hexadecimal Floating-Point

foo = 0x2.P1;
foo = 0x1729p2;
foo = 0x87539319P-3;
foo = 0x6_963_472_309_248P+4;


// Invalid

foo = 08;					// Zero can't start an integer

foo = 42_.00F;				// Underscore can't start or end number section
foo = 42._00F;
foo = _42;
foo = 42_;
foo = 042_;
foo = 0x42_;

foo = 123a;					// Word boundary test
foo = 3.59e-1701Da;
foo = 0x1729p2a;
foo = 0b1101a;
