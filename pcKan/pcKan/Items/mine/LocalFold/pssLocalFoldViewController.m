//
//  pssLocalFoldViewController.m
//  ofoBike
//
//  Created by admin on 2016/12/19.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import "pssLocalFoldViewController.h"
#import "pssLocalMoviePlayViewController.h"
#import "pSSMovieViewController.h"

@interface pssLocalFoldViewController ()

@end

@implementation pssLocalFoldViewController
{
    NSString *_folderPath;
    NSMutableArray *_subPaths;
    NSMutableArray *_subFiles;
    NSMutableArray *selectPaths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _folderPath = [_folderPath stringByStandardizingPath];
    selectPaths = [NSMutableArray array];
    
    [self fileNamesWithPath:_folderPath];
}

-(void)fileNamesWithPath:(NSString *)path
{
    NSError *error = nil;
    BOOL isDirectory = NO;
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    _subPaths = [NSMutableArray array];
    _subFiles = [NSMutableArray array];
    [_subPaths addObject:@".."];
    
    for (NSString *fileName in files) {
        NSString *fullFileName = [_folderPath stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] fileExistsAtPath:fullFileName isDirectory:&isDirectory];
        if (isDirectory) {
            [_subPaths addObject:fileName];
        }else{
            [_subFiles addObject:fileName];
        }
    }
    [self.tableView reloadData];
}

-(NSString *)nowSelectPaths
{
    NSString *nowPaths = @"";
    for (NSString *path in selectPaths) {
        nowPaths = [nowPaths stringByAppendingPathComponent:path];
    }
    return nowPaths;
}

-(NSInteger)eh_numberOfSections
{
    return 2;
}

-(NSInteger)eh_numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _subPaths.count;
    }else if (section == 1){
        return _subFiles.count;
    }
    return 0;
}

-(CGFloat)eh_cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return MarginH(50);
}

-(pSSBaseTableViewCell *)eh_cellAtIndexPath:(NSIndexPath *)indexPath
{
    pSSBaseTableViewCell *cell = [pSSBaseTableViewCell cellWithTableView:self.tableView];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = [NSString stringWithFormat:@"[]%@", _subPaths[indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } break;
        case 1: {
            cell.textLabel.text = _subFiles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } break;
        default:
            break;
    }
    return cell;
}

-(void)eh_didSelectCellAtIndexPath:(NSIndexPath *)indexPath cell:(pSSBaseTableViewCell *)cell
{
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                if (selectPaths.count > 0) {
                    [selectPaths removeLastObject];
                    NSString *path = [_folderPath stringByAppendingPathComponent:[self nowSelectPaths]];
                    [self fileNamesWithPath:path];
                }
            }else{
                NSString *fileName = _subPaths[indexPath.row];
                [selectPaths addObject:fileName];
                NSString *path = [_folderPath stringByAppendingPathComponent:[self nowSelectPaths]];
                [self fileNamesWithPath:path];
            }
        } break;
        case 1: {
            NSString *fileName = [NSString stringWithFormat:@"%@/%@", [self nowSelectPaths], _subFiles[indexPath.row]];
            fileName = [_folderPath stringByAppendingPathComponent:fileName];
//            pssLocalMoviePlayViewController *vc = [[pssLocalMoviePlayViewController alloc] initWithURL:[NSURL URLWithString:fileName]];
//            [self pushVc:vc];
            pSSMovieViewController *vc = [[pSSMovieViewController alloc] initWithFilePath:[NSURL URLWithString:fileName]];
            [self pushVc:vc];
        } break;
        default:
            break;
    }
}
@end
