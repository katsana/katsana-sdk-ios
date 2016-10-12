//
//  main.m
//  FastCoding
//
//  Created by Nick Lockwood on 09/12/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastCoder.h"

// the TestData.h file will be created at build time using the following shell script

// cd "${SRCROOT}/"
// /usr/bin/xxd -i "TestData.json" "MacBenchmark/TestData.h"

// which converts the TestData.json file into a header containing the following:

// unsigned char TestData_json[] = {...};
// unsigned int TestData_json_len = ...;

extern unsigned char TestData_json[];
extern unsigned int TestData_json_len;

#import "TestData.h"
#import <QuartzCore/QuartzCore.h>


static void LogLoading(NSString *, NSTimeInterval, NSTimeInterval, NSTimeInterval);
static void LogLoading(NSString *name, NSTimeInterval start, NSTimeInterval loaded, NSTimeInterval parsed)
{
    printf("%s loading: %.0f ms, parsing: %.0f ms, total: %.0f ms\n", [name UTF8String], (loaded - start) * 1000, (parsed - loaded) * 1000, (parsed - start) * 1000);
}

static void LogSaving(NSString *, NSTimeInterval, NSTimeInterval, NSTimeInterval, long long);
static void LogSaving(NSString *name, NSTimeInterval start, NSTimeInterval written, NSTimeInterval saved, long long bytes)
{
    printf("%s writing: %.0f ms, saving: %.0f ms, total: %.0f ms, size: %lld bytes\n", [name UTF8String], (written - start) * 1000, (saved - written) * 1000, (saved - start) * 1000, bytes);
}


int main(__unused int argc, __unused const char * argv[])
{
    @autoreleasepool
    {
        //load test data (encoded in the generated TestData.h file)
        NSData *data = [NSData dataWithBytes:TestData_json length:TestData_json_len];
        id object = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:NULL];
        
        NSString *KeyedArchivePath = [NSTemporaryDirectory() stringByAppendingString:@"test.nscoded"];
        NSString *FastArchivePath = [NSTemporaryDirectory() stringByAppendingString:@"test.fast"];
        
        //bootstrap the JSON data into real objects
        data = [FastCoder dataWithRootObject:object];
        object = [FastCoder objectWithData:data];
        
        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
        
        //write keyed archive
        data = [NSKeyedArchiver archivedDataWithRootObject:object];
        CFTimeInterval keyedArchiveWritten = CFAbsoluteTimeGetCurrent();
        
        //save keyed archive
        [data writeToFile:KeyedArchivePath atomically:NO];
        CFTimeInterval keyedArchiveSaved = CFAbsoluteTimeGetCurrent();
        LogSaving(@"Keyed Archive", start, keyedArchiveWritten, keyedArchiveSaved, (long long)[data length]);
        
        //load keyed archive
        data = [NSData dataWithContentsOfFile:KeyedArchivePath];
        CFTimeInterval keyedArchiveLoaded = CFAbsoluteTimeGetCurrent();
        
        //parse keyed archive
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        CFTimeInterval keyedArchiveParsed = CFAbsoluteTimeGetCurrent();
        LogLoading(@"Keyed Archive", keyedArchiveSaved, keyedArchiveLoaded, keyedArchiveParsed);

        //write fast archive
        data = [FastCoder dataWithRootObject:object];
        CFTimeInterval fastArchiveWritten = CFAbsoluteTimeGetCurrent();
        
        //save fast archive
        [data writeToFile:FastArchivePath atomically:NO];
        CFTimeInterval fastArchiveSaved = CFAbsoluteTimeGetCurrent();
        LogSaving(@"Fast Archive", keyedArchiveParsed, fastArchiveWritten, fastArchiveSaved, (long long)[data length]);
        
        //load fast archive
        data = [NSData dataWithContentsOfFile:FastArchivePath];
        CFTimeInterval fastArchiveLoaded = CFAbsoluteTimeGetCurrent();
        
        //parse fast archive
        [FastCoder objectWithData:data];
        CFTimeInterval fastArchiveParsed = CFAbsoluteTimeGetCurrent();
        LogLoading(@"Fast Archive", fastArchiveSaved, fastArchiveLoaded, fastArchiveParsed);
    }
    
    return 0;
}

