//
//  YQTimerListViewController.m
//  Interval Timer
//
//  Created by Yu Qiao on 12/22/13.
//  Copyright (c) 2013 Yu Qiao. All rights reserved.
//

#import "YQTimerListViewController.h"
#import "YQEditTimerViewController.h"
#import "Timer+TimerWithHelper.h"
#import <fittingTimer-Swift.h>

@interface YQTimerListViewController ()
{
    NSIndexPath *selectedIndex;
}

@property (nonatomic) NSFetchedResultsController *fetchedController;

@end

@implementation YQTimerListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //fetch timers from database. only do this for the first time
    NSError *error;
    if (![self.fetchedController performFetch:&error]) {
        //handle error here
        if(error){
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSUInteger count = [self.fetchedController.sections count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedController sections] objectAtIndex:section];
    
	NSInteger count = [sectionInfo numberOfObjects];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Timer *timer = [self.fetchedController objectAtIndexPath:indexPath];
    if ([timer.name length]) {
        cell.textLabel.text = timer.name;
    }else{
        cell.textLabel.text = @"Timer";
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Round: %@. Cycle: %@",[Timer getLengthInString:timer.roundLength],[timer.cycle stringValue]];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

//swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.managedObjectContext deleteObject:[self.fetchedController objectAtIndexPath:indexPath]];
    NSError *error;
    [self.managedObjectContext save:&error];
}


#pragma mark - fetched results controller
-(NSFetchedResultsController *)fetchedController
{
    if (!_fetchedController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entiry = [NSEntityDescription entityForName:@"Timer"
                                                  inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entiry];

        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[sort]];
        
        _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _fetchedController.delegate = self;
    }
    
    return _fetchedController;
}

#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    YQEditTimerViewController *destController = segue.destinationViewController;
    Timer *selectedTimer;
    if ([segue.identifier isEqualToString:@"add new timer"]) {
        destController.title = @"New Timer";
        //create a new timer
        selectedTimer =[NSEntityDescription insertNewObjectForEntityForName:@"Timer"
                                                    inManagedObjectContext:self.managedObjectContext];
        selectedTimer.warmUpLength = @0;
        selectedTimer.roundLength = @1;
        selectedTimer.restLength = @0;
        selectedTimer.cooldownLength = @0;
        selectedTimer.cycle = @1;
        selectedTimer.name = @"Timer";
        selectedTimer.creationTime = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
    }else if([segue.identifier isEqualToString:@"edit timer"]){
        destController.title = @"Edit Timer";
        selectedTimer = [self.fetchedController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
    //pass the timer and context
    destController.timer = selectedTimer;
    destController.managedObjectContext = self.managedObjectContext;
}

#pragma mark - view
-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (IBAction)toggleMenu:(id)sender {
    [self toggleSideMenuView];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
