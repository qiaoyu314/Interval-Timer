//
//  YQEditTimerViewController.m
//  Interval Timer
//
//  Created by Yu Qiao on 12/25/13.
//  Copyright (c) 2013 Yu Qiao. All rights reserved.
//

#import "YQEditTimerViewController.h"
#import "YQCountDownViewController.h"
#import <Interval_Timer-Swift.h>

#define PICKER_ROW 0
#define WARM_UP_ROW 0
#define ROUND_ROW 1
#define REST_ROW 2
#define COOL_DOWN_ROW 3
#define CYCLE_ROW 4
#define TOTAL_ROW 5
#define NAME_ROW 6

#define MAX_CYCLE 100


@interface YQEditTimerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (weak, nonatomic) IBOutlet UILabel *warmUpLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *roundLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *restLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *coolDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentEditingLabel;
@property (weak, nonatomic) IBOutlet UITextField *cycleTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *standardDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *standardTitleLabel;
@property NSMutableArray *timePickDataArray;   //contains 3 arrays.
@property (nonatomic) BOOL showTimePicker;

- (void) udpateTimePicker:(NSInteger)row;

@end

@implementation YQEditTimerViewController{
    NSInteger selectedRow;
    NSInteger lastSelectedRow;
}

@synthesize showTimePicker = _showTimePicker;

-(void)setShowTimePicker:(BOOL)showTimePicker{
    _showTimePicker = showTimePicker;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize data array for time picker
    self.timePickDataArray = [NSMutableArray arrayWithCapacity:3];
    
    //hour array
    NSMutableArray *hourArray = [NSMutableArray arrayWithCapacity:24];
    for (int i=0; i<24; i++) {
        [hourArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.timePickDataArray addObject:hourArray];
    
    //minute and second array
    NSMutableArray *minuteArray = [NSMutableArray arrayWithCapacity:60];
    NSMutableArray *secondArray = [NSMutableArray arrayWithCapacity:60];
    for (int i=0; i<60; i++) {
        NSString *tempString;
        tempString = [NSString stringWithFormat:@"%d",i];
        [minuteArray addObject:tempString];
        [secondArray addObject:tempString];
    }
    [self.timePickDataArray addObject:minuteArray];
    [self.timePickDataArray addObject:secondArray];
    
    
    //update labels in cells
    self.warmUpLabel.text = [Timer getLengthInString:self.timer.warmUpLength];
    self.roundLengthLabel.text = [Timer getLengthInString:self.timer.roundLength];
    self.restLengthLabel.text = [Timer getLengthInString:self.timer.restLength];
    self.coolDownLabel.text = [Timer getLengthInString:self.timer.cooldownLength];
    self.cycleTextField.text = [self.timer.cycle stringValue];
    self.nameTextField.text =self.timer.name;
    self.totalLabel.text = [Timer getLengthInString:[self.timer getTotal]];
    //connect time picker with round length
    selectedRow = -1;
    self.showTimePicker = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self autoAlign];
}

-(void)viewdidDisappear{
    [self.managedObjectContext save:NULL];
}

-(void)autoAlign{
    NSLayoutConstraint  *cycleLableleadingSpaceConstrain = [NSLayoutConstraint constraintWithItem:self.cycleLabel attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.standardTitleLabel attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0];
    NSLayoutConstraint  *cycFieldleadingSpaceConstrain = [NSLayoutConstraint constraintWithItem:self.cycleTextField attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.standardDetailLabel attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0];
    NSLayoutConstraint  *nameLableleadingSpaceConstrain = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.standardTitleLabel attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0];
    NSLayoutConstraint  *nameFieldleadingSpaceConstrain = [NSLayoutConstraint constraintWithItem:self.nameTextField attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.standardDetailLabel attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0];
    
    NSLayoutConstraint  *cycleFieldWidthConstrain = [NSLayoutConstraint constraintWithItem:self.cycleTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.standardDetailLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint  *nameFieldWidthConstrain = [NSLayoutConstraint constraintWithItem:self.nameTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.standardDetailLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.view addConstraint: cycleLableleadingSpaceConstrain];
    [self.view addConstraint: cycFieldleadingSpaceConstrain];
    [self.view addConstraint: nameLableleadingSpaceConstrain];
    [self.view addConstraint: nameFieldleadingSpaceConstrain];
    [self.view addConstraint: cycleFieldWidthConstrain];
    [self.view addConstraint: nameFieldWidthConstrain];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return self.showTimePicker?1:0;
            break;
        case 1:
            return 7;
            break;
        default:
            return 1;
            break;
    }
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedRow = selectedRow;
    selectedRow = indexPath.row;
    if (indexPath.section == 1) {
        if(selectedRow <= COOL_DOWN_ROW){
            self.showTimePicker = YES;
            //auto scroll to the picker
            NSIndexPath *pickerIndex = [NSIndexPath indexPathForRow:PICKER_ROW inSection:0];
            [self.tableView scrollToRowAtIndexPath:pickerIndex atScrollPosition:UITableViewScrollPositionTop animated:true];
        }else{
            self.showTimePicker = NO;
        }
        
        //set the title above the picker
        //get the title
        NSString *currentTitle;
        switch (selectedRow) {
            case WARM_UP_ROW:
                currentTitle = [NSString stringWithFormat:@"WARM UP"];
                break;
            case ROUND_ROW:
                currentTitle = [NSString stringWithFormat:@"ROUND"];
                break;
            case REST_ROW:
                currentTitle = [NSString stringWithFormat:@"REST"];
                break;
            case COOL_DOWN_ROW:
                currentTitle = [NSString stringWithFormat:@"COOL DOWN"];
                break;
            default:
                currentTitle = [NSString stringWithFormat:@""];
                break;
        }
        self.currentEditingLabel.text = [NSString stringWithFormat:@"Set the %@ time",currentTitle];
        
        //update time picker to match the selected row;
        if (lastSelectedRow != selectedRow) {
            [self udpateTimePicker:selectedRow];
        }
        //focus on text field
        if (selectedRow == CYCLE_ROW) {
            [[tableView cellForRowAtIndexPath:indexPath] resignFirstResponder];
            [self.cycleTextField becomeFirstResponder];
        }else if (selectedRow == NAME_ROW){
            [[tableView cellForRowAtIndexPath:indexPath] resignFirstResponder];
            [self.nameTextField becomeFirstResponder];
        }
    }
    
}


#pragma mark - Picker view data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.timePickDataArray count];
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self.timePickDataArray objectAtIndex:component] count];
}

#pragma mark - Picker view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.timePickDataArray objectAtIndex:component] objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Not allow 00:00:00
    if((selectedRow == ROUND_ROW) && ([pickerView selectedRowInComponent:0] == 0) && ([pickerView selectedRowInComponent:1] == 0) && ([pickerView selectedRowInComponent:2] == 0)){
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    
    NSInteger hours = [pickerView selectedRowInComponent:0];
    NSInteger minutes = [pickerView selectedRowInComponent:1];
    NSInteger seconds = [pickerView selectedRowInComponent:2];
    NSNumber *interval = [[NSNumber alloc]initWithInteger: hours*3600 + minutes*60 + seconds];
    NSString *labelText = [Timer getLengthInString:interval];
    switch (selectedRow) {
        case WARM_UP_ROW:
            self.timer.warmUpLength = interval;
            self.warmUpLabel.text = labelText;
            break;
        case ROUND_ROW:
            self.timer.roundLength = interval;
            self.roundLengthLabel.text = labelText;
            break;
        case REST_ROW:
            self.timer.restLength = interval;
            self.restLengthLabel.text = labelText;
            break;
        case COOL_DOWN_ROW:
            self.timer.cooldownLength = interval;
            self.coolDownLabel.text = labelText;
            break;
        default:
            break;
    }
    self.totalLabel.text = [Timer getLengthInString:[self.timer getTotal]];
}
#pragma mark - text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - cycle cell

//Update the cycle based on the value in the cycle field.
//This method will be called the view disppears.
- (BOOL)updateCycle
{
    if ([self.cycleTextField.text intValue] < 1 || [self.cycleTextField.text intValue] > MAX_CYCLE) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cycle Error" message:@"Cycle has be between 1 and 100." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.cycleTextField.text = @"1";
        [self.cycleTextField becomeFirstResponder];
        return false;
    }else{
        self.timer.cycle = [NSNumber numberWithInt:[self.cycleTextField.text intValue]];
        self.totalLabel.text = [Timer getLengthInString:[self.timer getTotal]];
        return true;
    }
}

#pragma mark - name cell
- (BOOL)updateName
{
    self.timer.name = self.nameTextField.text;
    return true;
}




#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //udpate the cycle
    if([self updateCycle] && [self updateName]){
        return true;
    }
    
    return false;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destController = segue.destinationViewController;
    if([segue.identifier  isEqualToString: @"countDown"]){
        //udpate the cycle
        if ([destController isKindOfClass:[YQCountDownViewController class]]) {
            ((YQCountDownViewController *)destController).timer = self.timer;
        }
    }else if([segue.identifier isEqualToString:@"share"]){
        if ([destController isKindOfClass:[YQShareViewController class]]) {
            ((YQShareViewController *)destController).timer = self.timer;
        }
    }
    
    
}



#pragma mark other methods
//update the time picker to match the selected table row
- (void) udpateTimePicker:(NSInteger)row
{
    NSInteger hourRow = 0;
    NSInteger minuteRow = 0;
    NSInteger secondRow = 0;
    if (row == 0) {
        //warm up
        hourRow = [[Timer getHours:self.timer.warmUpLength] integerValue];
         minuteRow = [[Timer getMinutes:self.timer.warmUpLength] integerValue];
        secondRow = [[Timer getSeconds:self.timer.warmUpLength] integerValue];
        
    }else if(row == 1){
        //round
        hourRow = [[Timer getHours:self.timer.roundLength] integerValue];
        minuteRow = [[Timer getMinutes:self.timer.roundLength] integerValue];
        secondRow = [[Timer getSeconds:self.timer.roundLength] integerValue];
    }else if(row == 2){
        //rest
        hourRow = [[Timer getHours:self.timer.restLength] integerValue];
        minuteRow = [[Timer getMinutes:self.timer.restLength] integerValue];
        secondRow = [[Timer getSeconds:self.timer.restLength] integerValue];
    }else if(row == 3){
        //cool down
        hourRow = [[Timer getHours:self.timer.cooldownLength] integerValue];
        minuteRow = [[Timer getMinutes:self.timer.cooldownLength] integerValue];
        secondRow = [[Timer getSeconds:self.timer.cooldownLength] integerValue];
    }
    if (row < 4) {
        [self.timePicker selectRow:hourRow inComponent:0 animated:YES];
        [self.timePicker selectRow:minuteRow inComponent:1 animated:YES];
        [self.timePicker selectRow:secondRow inComponent:2 animated:YES];
    }
    
}



@end
