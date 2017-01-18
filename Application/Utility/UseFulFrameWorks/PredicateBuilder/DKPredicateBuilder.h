//
//  DKPredicateBuilder.h
//  DiscoKit
//
//  Created by Keith Pitt on 12/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DKPredicate.h"

typedef void (^DKQueryFinishBlock)(NSArray *records, NSError *error);

@interface DKPredicateBuilder : NSObject {
	NSMutableArray *predicates;
	NSMutableArray *sorters;

	NSNumber *limit;
	NSNumber *offset;
}

@property (nonatomic, strong) NSMutableArray *predicates;
@property (nonatomic, strong) NSMutableArray *sorters;
@property (nonatomic, strong) NSNumber *limit;
@property (nonatomic, strong) NSNumber *offset;

- (id)DK_where:(DKPredicate *)predicate;

- (id)DK_where:(NSString *)key isFalse:(BOOL)value;
- (id)DK_where:(NSString *)key isTrue:(BOOL)value;

- (id)DK_where:(NSString *)key isNull:(BOOL)value;
- (id)DK_where:(NSString *)key isNotNull:(BOOL)value;

- (id)DK_where:(NSString *)key equals:(id)value;
- (id)DK_where:(NSString *)key doesntEqual:(id)value;

- (id)DK_where:(NSString *)key isIn:(NSArray *)values;
- (id)DK_where:(NSString *)key isNotIn:(NSArray *)values;

- (id)DK_where:(NSString *)key startsWith:(NSString *)value;
- (id)DK_where:(NSString *)key doesntStartWith:(NSString *)value;
- (id)DK_where:(NSString *)key endsWith:(NSString *)value;
- (id)DK_where:(NSString *)key doesntEndWith:(NSString *)value;

- (id)DK_where:(NSString *)key contains:(NSString *)value;
- (id)DK_where:(NSString *)key like:(NSString *)value;

- (id)DK_where:(NSString *)key greaterThan:(id)value;
- (id)DK_where:(NSString *)key greaterThanOrEqualTo:(id)value;
- (id)DK_where:(NSString *)key lessThan:(id)value;
- (id)DK_where:(NSString *)key lessThanOrEqualTo:(id)value;
- (id)DK_where:(NSString *)key between:(id)first andThis:(id)second;

- (id)orderBy:(NSString *)column ascending:(BOOL)ascending;

- (id)limit:(int)value;
- (id)offset:(int)value;

- (NSCompoundPredicate *)compoundPredicate;

@end
