//
//  DKPredicateBuilder.m
//  DiscoKit
//
//  Created by Keith Pitt on 12/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKPredicateBuilder.h"

@implementation DKPredicateBuilder

@synthesize predicates, sorters, limit, offset;

- (id)init {
	if ((self = [super init])) {
		// Create the predicates mutable array
		predicates = [[NSMutableArray alloc] init];

		// Create the sorters mutable array
		sorters = [[NSMutableArray alloc] init];
	}

	return self;
}

- (id)DK_where:(DKPredicate *)predicate {
	[self.predicates addObject:predicate];

	return self;
}

- (id)DK_where:(NSString *)key isFalse:(BOOL)value {
	[self DK_where:key isTrue:!value];

	return self;
}

- (id)DK_where:(NSString *)key isTrue:(BOOL)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, [NSNumber numberWithBool:value]]
	                         predicateType:value ? DKPredicateTypeIsTrue:DKPredicateTypeIsFalse
	                                  info:[NSDictionary dictionaryWithObject:key forKey:@"column"]]];

	return self;
}

- (id)DK_where:(NSString *)key isNull:(BOOL)value {
	if (value == YES) {
		[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K == nil", key]
		                         predicateType:value ? DKPredicateTypeIsTrue:DKPredicateTypeIsFalse
		                                  info:[NSDictionary dictionaryWithObject:key forKey:@"column"]]];
	}
	else {
		[self DK_where:key isNotNull:YES];
	}

	return self;
}

- (id)DK_where:(NSString *)key isNotNull:(BOOL)value {
	if (value == YES) {
		[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K != nil", key]
		                         predicateType:value ? DKPredicateTypeIsTrue:DKPredicateTypeIsFalse
		                                  info:[NSDictionary dictionaryWithObject:key forKey:@"column"]]];
	}
	else {
		[self DK_where:key isNull:YES];
	}

	return self;
}

- (id)DK_where:(NSString *)key equals:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value]
	                         predicateType:DKPredicateTypeEquals
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key doesntEqual:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K != %@", key, value]
	                         predicateType:DKPredicateTypeNotEquals
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key isIn:(NSArray *)values {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K IN (%@)", key, values]
	                         predicateType:DKPredicateTypeIn
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        values, @"values",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key isNotIn:(NSArray *)values {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"NOT %K IN (%@)", key, values]
	                         predicateType:DKPredicateTypeNotIn
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        values, @"values",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key startsWith:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", key, value]
	                         predicateType:DKPredicateTypeStartsWith
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key doesntStartWith:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"NOT %K BEGINSWITH[cd] %@", key, value]
	                         predicateType:DKPredicateTypeDoesntStartWith
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key endsWith:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K ENDSWITH[cd] %@", key, value]
	                         predicateType:DKPredicateTypeEndsWith
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key doesntEndWith:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"NOT %K ENDSWITH[cd] %@", key, value]
	                         predicateType:DKPredicateTypeDoesntEndWith
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key contains:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", key, value]
	                         predicateType:DKPredicateTypeContains
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key like:(NSString *)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", key, value]
	                         predicateType:DKPredicateTypeLike
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key greaterThan:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K > %@", key, value]
	                         predicateType:DKPredicateTypeGreaterThan
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key greaterThanOrEqualTo:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K >= %@", key, value]
	                         predicateType:DKPredicateTypeGreaterThanOrEqualTo
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key lessThan:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K < %@", key, value]
	                         predicateType:DKPredicateTypeLessThan
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key lessThanOrEqualTo:(id)value {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"%K <= %@", key, value]
	                         predicateType:DKPredicateTypeLessThanOrEqualTo
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        value, @"value",
	                                        nil]]];

	return self;
}

- (id)DK_where:(NSString *)key between:(id)first andThis:(id)second {
	[self DK_where:[DKPredicate withPredicate:[NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K < %@)", key, first, key, second]
	                         predicateType:DKPredicateTypeBetween
	                                  info:[NSDictionary dictionaryWithObjectsAndKeys:
	                                        key, @"column",
	                                        first, @"first",
	                                        second, @"second",
	                                        nil]]];

	return self;
}

- (id)orderBy:(NSString *)column ascending:(BOOL)ascending {
	// Create the sort descriptor
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:column
	                                                     ascending:ascending];

	// Add it to the sorters array
	[self.sorters addObject:sort];

	// Release the sort

	return self;
}

- (id)offset:(int)value {
	// Set the offset
	self.offset = [NSNumber numberWithInt:value];

	return self;
}

- (id)limit:(int)value {
	// Set the limit
	self.limit = [NSNumber numberWithInt:value];

	return self;
}

- (NSCompoundPredicate *)compoundPredicate {
	// Collect all the predicates
	NSMutableArray *collectedPredicates = [NSMutableArray array];
	for (DKPredicate *relPredicate in predicates) {
		[collectedPredicates addObject:relPredicate.predicate];
	}

	// Add the predicates to a NSCompoundPredicate
	NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType
	                                                                     subpredicates:collectedPredicates];

	return compoundPredicate;
}

@end
