#!/usr/bin/env zsh

mandelbrot() {
  local lines columns hue a b p q i pnew
  ((columns=COLUMNS-1, lines=LINES-1, hue=0))
  for ((b=-1.5; b<=1.5; b+=3.0/lines)) do
    for ((a=-2.0; a<=1; a+=3.0/columns)) do
      for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)) do
        ((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew))
      done
      ((hue=(i/4)%8))
      echo -n "\\e[4${hue}m "
    done
    echo
  done
}

mandelbrot
read junk

