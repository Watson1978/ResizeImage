//
//  main.m
//  ResizeImage
//
//  Created by Watson on 11/09/20.
//
#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
