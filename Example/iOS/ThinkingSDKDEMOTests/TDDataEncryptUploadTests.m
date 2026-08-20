//
//  TDDataEncryptUploadTests.m
//  ThinkingSDKDEMOTests
//
//  Mock / instrumented-style tests for report-data AES-GCM encryption and
//  mixed-batch compatibility with legacy ciphertext rows already in the local DB.
//

#import <XCTest/XCTest.h>
#import <ThinkingSDK/ThinkingSDK.h>
#import <ThinkingSDK/TDEncryptManager.h>
#import <ThinkingSDK/TDSecretKey.h>
#import <ThinkingSDK/TDSqliteDataQueue.h>
#import <ThinkingSDK/TDEventRecord.h>
#import <ThinkingSDK/TDFile.h>

#if __has_include(<ThinkingDataCore/TDAESEncryptor.h>)
#import <ThinkingDataCore/TDAESEncryptor.h>
#else
#import "TDAESEncryptor.h"
#endif

@interface TDDataEncryptUploadTests : XCTestCase
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *instanceName;
@end

@implementation TDDataEncryptUploadTests

// Fixed RSA public key (SPKI / X.509), same shape as production encrypt config.
static NSString * const kTestEncryptPublicKey =
    @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAti6FnWGv7Lggzg/R8hQa"
    @"4GEtd2ucfntqo6Xkf1sPwCIfndr2u6KGPhWQ24bFUKgtNLDuKnUAg1C/OEEL8uON"
    @"JBdbX9XpckO67tRPSPrY3ufNIxsCJ9td557XxUsnebkOZ+oC1Duk8/ENx1pRvU6S"
    @"4c+UYd6PH8wxw1agD61oJ0ju3CW0aZNZ2xKcWBcIU9KgYTeUtawrmGU5flod88Cq"
    @"Zc8VKB1+nY0tav023jvxwkM3zgQ6vBWIU9/aViGECB98YEzJfZjcOTD6zvqsZc/W"
    @"RnUNhBHFPGEwc8ueMvzZNI+FP0pUFLVRwVoYbj/tffKbxGExaRFIcgP73BIW6/6n"
    @"QwIDAQAB";

static NSString * const kLegacyEcbEnvelopeEKey = @"LEGACY_RSA_WRAPPED_AES_KEY";
static NSString * const kLegacyEcbEnvelopePayload = @"LEGACY_AES_ECB_CIPHERTEXT_PLACEHOLDER";

- (NSDictionary *)legacyEcbEnvelope {
    // Pre-GCM rows stored in DB only have ekey/pkv/payload (no mode).
    return @{
        @"ekey": kLegacyEcbEnvelopeEKey,
        @"pkv": @1,
        @"payload": kLegacyEcbEnvelopePayload,
    };
}

- (void)setUp {
    [super setUp];
    self.appId = [[NSUUID UUID] UUIDString];
    self.instanceName = [NSString stringWithFormat:@"EncryptTest_%@", self.appId];

    // Encryption is gated on the receiver's AES-GCM support. Simulate a launch where the flag
    // is already known (second launch / seeded), matching Android seedGcmSupport.
    TDFile *file = [[TDFile alloc] initWithAppid:self.appId];
    [file archiveEncryptSupportGcm:@(1)];

    TDConfig *config = [[TDConfig alloc] init];
    config.appid = self.appId;
    config.serverUrl = @"https://receiver-ta-demo.thinkingdata.cn";
    config.name = self.instanceName;
    config.mode = TDModeNormal;
    [config enableEncryptWithVersion:1 publicKey:kTestEncryptPublicKey];
    [TDAnalytics startAnalyticsWithConfig:config];

    // Clear any leftover rows for this instance token.
    [[TDSqliteDataQueue sharedInstanceWithAppid:self.instanceName] deleteAll:self.instanceName];
}

- (void)tearDown {
    [[TDSqliteDataQueue sharedInstanceWithAppid:self.instanceName] deleteAll:self.instanceName];
    [super tearDown];
}

#pragma mark - Helpers

- (BOOL)waitForRecordCount:(NSUInteger)minCount timeout:(NSTimeInterval)timeout {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];
    TDSqliteDataQueue *queue = [TDSqliteDataQueue sharedInstanceWithAppid:self.instanceName];
    while ([NSDate date].timeIntervalSince1970 < deadline.timeIntervalSince1970) {
        if ([queue sqliteCountForAppid:self.instanceName] >= (NSInteger)minCount) {
            return YES;
        }
        [NSThread sleepForTimeInterval:0.05];
    }
    return [queue sqliteCountForAppid:self.instanceName] >= (NSInteger)minCount;
}

- (NSData *)td_dataFromHex:(NSString *)hex {
    NSMutableData *data = [NSMutableData dataWithCapacity:hex.length / 2];
    for (NSUInteger i = 0; i + 1 < hex.length; i += 2) {
        unsigned int byte = 0;
        [[NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(i, 2)]] scanHexInt:&byte];
        uint8_t b = (uint8_t)byte;
        [data appendBytes:&b length:1];
    }
    return data;
}

#pragma mark - Tests

- (void)testEncryptJSONObject_includesModeGcm {
    TDSecretKey *secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:kTestEncryptPublicKey];
    TDEncryptManager *manager = [[TDEncryptManager alloc] initWithSecretKey:secretKey];
    XCTAssertTrue(manager.isValid);

    NSDictionary *envelope = [manager encryptJSONObject:@{
        @"#type": @"track",
        @"#event_name": @"gcm_encrypt_event",
    }];
    XCTAssertNotNil(envelope);
    XCTAssertEqualObjects(envelope[@"mode"], @"gcm");
    XCTAssertNotNil(envelope[@"ekey"]);
    XCTAssertNotNil(envelope[@"pkv"]);
    XCTAssertTrue([envelope[@"payload"] isKindOfClass:NSString.class]);
    XCTAssertGreaterThan([envelope[@"payload"] length], 0U);
}

- (void)testAESGCM_roundTripDecryptsOriginal {
    TDAESEncryptor *aes = [[TDAESEncryptor alloc] init];
    aes.key = @"0123456789abcdef";
    NSData *plain = [@"{\"#event_name\":\"purchase\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *combined = [aes encryptData:plain];
    XCTAssertNotNil(combined);
    XCTAssertGreaterThan(combined.length, 12U + 16U);

    NSData *decrypted = [aes decryptData:combined];
    XCTAssertEqualObjects(decrypted, plain);

    // Random IV => non-deterministic ciphertext.
    NSData *combined2 = [aes encryptData:plain];
    XCTAssertNotEqualObjects(combined, combined2);
}

/// Byte-compatibility guard: decrypt an AES-128-GCM envelope produced by an
/// independent implementation (OpenSSL). Proves the public-API GCM rewrite stays
/// interoperable with the standard / the Android SDK / the previous ciphertext.
/// key="0123456789abcdef", IV=000102030405060708090a0b, no AAD, 128-bit tag.
- (void)testAESGCM_decryptsStandardOpenSSLVector {
    TDAESEncryptor *aes = [[TDAESEncryptor alloc] init];
    aes.key = @"0123456789abcdef";
    NSData *blob = [self td_dataFromHex:
        @"000102030405060708090a0b861de77868115542b7486677a5b98a0f70a2259"
        @"96fd2392e5545c8d09bd2db097c2dbd9a828ffbac485a95866fbd64e0ca12e42"
        @"dcfbaa0b58665"];
    NSData *decrypted = [aes decryptData:blob];
    NSString *plaintext = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(plaintext, @"{\"#event_name\":\"purchase\",\"#type\":\"track\"}");
}

/// A flipped tag byte must fail authentication (GHASH tag verify).
- (void)testAESGCM_tamperedTagRejected {
    TDAESEncryptor *aes = [[TDAESEncryptor alloc] init];
    aes.key = @"0123456789abcdef";
    NSData *plain = [@"{\"k\":\"v\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *combined = [[aes encryptData:plain] mutableCopy];
    XCTAssertNotNil(combined);
    uint8_t *bytes = combined.mutableBytes;
    bytes[combined.length - 1] ^= 0x01;
    XCTAssertNil([aes decryptData:combined]);
}

/// Envelopes not longer than IV(12)+tag(16) cannot be valid and must return nil.
- (void)testAESGCM_shortInputReturnsNil {
    TDAESEncryptor *aes = [[TDAESEncryptor alloc] init];
    aes.key = @"0123456789abcdef";
    XCTAssertNil([aes decryptData:[NSMutableData dataWithLength:28]]);
    XCTAssertNil([aes decryptData:[NSData data]]);
}

/**
 * DB already has a legacy encrypted row (no mode field, historically AES-ECB).
 * A newly tracked event is encrypted with AES-GCM (mode=gcm).
 * One batch read must include both envelopes without conversion.
 */
- (void)testFlush_dbHasLegacyEcbRow_batchContainsLegacyAndGcm {
    TDSqliteDataQueue *queue = [TDSqliteDataQueue sharedInstanceWithAppid:self.instanceName];
    NSInteger inserted = [queue addObject:[self legacyEcbEnvelope] withAppid:self.instanceName];
    XCTAssertGreaterThanOrEqual(inserted, 1);

    [TDAnalytics track:@"new_gcm_after_legacy"
            properties:@{@"source": @"TDDataEncryptUploadTests"}
             withAppId:self.instanceName];

    XCTAssertTrue([self waitForRecordCount:2 timeout:5.0],
                  @"expected legacy + newly encrypted GCM row in DB");

    NSArray<TDEventRecord *> *records = [queue getFirstRecords:10 withAppid:self.instanceName];
    XCTAssertGreaterThanOrEqual(records.count, 2U);

    BOOL foundLegacy = NO;
    BOOL foundGcm = NO;
    for (TDEventRecord *record in records) {
        XCTAssertTrue(record.encrypted, @"each item must look encrypted");
        NSDictionary *item = record.event;
        XCTAssertNotNil(item[@"ekey"]);
        XCTAssertNotNil(item[@"payload"]);
        XCTAssertNotNil(item[@"pkv"]);

        if (item[@"mode"] == nil) {
            foundLegacy = YES;
            XCTAssertEqualObjects(item[@"ekey"], kLegacyEcbEnvelopeEKey);
            XCTAssertEqualObjects(item[@"payload"], kLegacyEcbEnvelopePayload);
        } else if ([item[@"mode"] isEqualToString:@"gcm"]) {
            foundGcm = YES;
            XCTAssertGreaterThan([item[@"ekey"] length], 0U);
            XCTAssertGreaterThan([item[@"payload"] length], 0U);
        }
    }
    XCTAssertTrue(foundLegacy, @"batch must keep legacy ECB envelope as-is");
    XCTAssertTrue(foundGcm, @"batch must include new GCM envelope with mode=gcm");
}

@end
