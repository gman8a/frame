These output files can be viewed using UTF-8 character mapping, 
  which is standard in modern terminals and web portals.
  
They were produces using the linux bash call mk_output, which pipes the framed output through iconv.

  ex. ~/frame/math_forms$ cat CARRY-15.FRM|./frame|iconv --from-code=IBM437 --to-code=UTF-8
  
  see file: mk_output
  
