//
//  CustomTableView.m
//  UI实验
//
//  Created by 张晓波 on 12/29/11.
//  Copyright (c) 2011 SEU. All rights reserved.
//

#import "CustomNoFooterViewSectionHeaderTableView.h"

@implementation CustomNoFooterViewSectionHeaderTableView
@synthesize mTableView;
@synthesize mContentOffset;
@synthesize mRefreshTableHeaderView;
@synthesize mRefreshTableFooterView;

- (id)initWithFrame:(CGRect)frame Delegate:(id)delegate
{
    mDelegate = delegate;
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        mTableView = [[UITableView alloc] initWithFrame:self.bounds];
        mTableView.dataSource = self;
        mTableView.delegate = self;
        mTableView.directionalLockEnabled = YES;
        mTableView.decelerationRate = 0;
        mTableViewCellNum = 0;
        [mTableView setClipsToBounds:NO];
        
        mRefreshTableHeaderView = [[RefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -mTableView.frame.size.height, mTableView.bounds.size.width, mTableView.bounds.size.height)];
        mRefreshTableHeaderView.delegate = self;
        [mTableView addSubview:mRefreshTableHeaderView];
        
        mRefreshTableFooterView = [[RefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, mTableView.frame.size.height, mTableView.bounds.size.width, mTableView.bounds.size.height) SuperScollHeight:mTableView.bounds.size.height];
        mRefreshTableFooterView.delegate = self;
        //[mTableView addSubview:mRefreshTableFooterView];
        
        [self addSubview:mTableView];
        
        isHeaderDataLoading = NO;
        isFooterDataLoading = NO;
    }
    return self;
}

-(void)removeFooterView
{
    [mRefreshTableFooterView removeFromSuperview];
}

-(void)dealloc
{
    [mRefreshTableHeaderView release];
    [mRefreshTableFooterView release];
    [mTableView release];
    
    [super dealloc];
}

/**************************  tableview Delegate ***************************/
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([mDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
        return [mDelegate tableView:tableView titleForHeaderInSection:section];
    else {
        return nil;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([mDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
        return [mDelegate tableView:tableView viewForHeaderInSection:section];
    else {
        return nil;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    if([mDelegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
        return [mDelegate tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    else {
        return -1;
    }
    return -1;
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if([mDelegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
        return [mDelegate sectionIndexTitlesForTableView:tableView];
    else {
        return nil;
    }
    return nil;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if([mDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
        return [mDelegate numberOfSectionsInTableView:tableView];
    else {
        return 1;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([mDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
        mTableViewCellNum = [mDelegate tableView:tableView numberOfRowsInSection:section];
    else
        mTableViewCellNum = 0;
    if (mTableViewCellNum == 0) {
        [mRefreshTableFooterView refreshFrameBySuperContetnHeight:2000];
    }
    return mTableViewCellNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([mDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
        return [mDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath   
{
    static CGFloat height = 0.0;
    if([mDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
        height = [mDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    else
        height =  0.0f;
       
    if (0 == indexPath.row) 
        mTableViewContentHeight = height;
    else
        mTableViewContentHeight += height;

    if((indexPath.row+1) == mTableViewCellNum)  
        [mRefreshTableFooterView refreshFrameBySuperContetnHeight:mTableViewContentHeight];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([mDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        [mDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    else
        return;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([mDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
        [mDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    else
        return;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    mContentOffset = scrollView.contentOffset.y;
    [mRefreshTableHeaderView refreshScrollViewDidScroll:scrollView];
    //[mRefreshTableFooterView refreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [mRefreshTableHeaderView refreshScrollViewDidEndDragging:scrollView];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


/**************************  refreshHeaderView Delegate ***************************/
- (void)refreshTableHeaderDidTriggerRefresh:(RefreshTableHeaderView*)view
{
    isHeaderDataLoading = YES;
    if([mDelegate respondsToSelector:@selector(refreshTableHeaderDidTriggerRefresh:)])
    {
        [mDelegate refreshTableHeaderDidTriggerRefresh:(RefreshTableHeaderView *)mTableView];
    }
}

- (BOOL)refreshTableHeaderDataSourceIsLoading:(RefreshTableHeaderView*)view
{
    return isHeaderDataLoading || isFooterDataLoading;
}

- (NSDate*)refreshTableHeaderDataSourceLastUpdated:(RefreshTableHeaderView*)view
{
    return [NSDate date];
}

/**************************  refreshFooterView Delegate ***************************/
- (void)refreshTableFooterDidTriggerRefresh:(RefreshTableFooterView*)view
{
    isFooterDataLoading = YES;
    if([mDelegate respondsToSelector:@selector(refreshTableFooterDidTriggerRefresh:)])
        [mDelegate refreshTableFooterDidTriggerRefresh:(RefreshTableFooterView *)mTableView];
}

- (BOOL)refreshTableFooterDataSourceIsLoading:(RefreshTableFooterView*)view
{
    return isFooterDataLoading || isHeaderDataLoading;
}

- (NSDate*)refreshTableFooterDataSourceLastUpdated:(RefreshTableFooterView*)view
{
    return [NSDate date];
}


/**************************   Data refresh method ****************************/
-(void)reloadData
{
    [mTableView reloadData];
    [mRefreshTableHeaderView refreshScrollViewDataSourceDidFinishedLoading:mTableView];
    //[mRefreshTableFooterView refreshScrollViewDataSourceDidFinishedLoading:mTableView];
    isHeaderDataLoading = NO;
    isFooterDataLoading = NO;
}

-(void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [mRefreshTableHeaderView refreshScrollViewDataSourceDidFinishedLoading:mTableView];
    //[mRefreshTableFooterView refreshScrollViewDataSourceDidFinishedLoading:mTableView];
    isHeaderDataLoading = NO;
    isFooterDataLoading = NO;
    [mTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

-(NSIndexPath *)indexPathForCell:(UITableViewCell *)tableViewCell
{
    return [mTableView indexPathForCell:tableViewCell];
}

-(void)setCustomTableViewTag:(NSInteger)tag
{
    [self setTag:tag];
    [mTableView setTag:tag];
}

@end
