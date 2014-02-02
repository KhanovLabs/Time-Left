//
//  SKAddEventTableViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 12/25/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import "SKAddEventTableViewController.h"
#import "SKAppDelegate.h"

static NSInteger kTextFieldSection = 0;
static NSInteger kNameCellIndex = 0;
static NSInteger kDescriptionCellIndex = 1;

static NSInteger kDatePickerSection = 1;
static NSInteger kStartDatePickerIndex = 1;
static NSInteger kEndDatePickerIndex = 3;
static NSInteger kDatePickerCellHeight = 216;

static NSString *kNameTextFieldPlaceholder = @"Name";
static NSString *kDescriptionTextFieldTextFieldPlaceholder = @"Description (optional)";
static NSString *kEndsDateDefaultString = @"Choose...";

static NSString *kErrorEmptyNameTitle = @"Empty Name";
static NSString *kErrorEmptyNameMessage = @"Please give a name to the event.";
static NSString *kErrorEmptyNameCancel = @"OK";

@interface SKAddEventTableViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIColor *cellBackgroundColor;

@end

@implementation SKAddEventTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

#pragma mark - Load and setup view

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDateLabels];
    [self signUpForKeyboardNotifications];
    [self setupColors];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
    [self setupDatePickers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupColors
{
    SKAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSDictionary *colors = [delegate currentTheme];
    // Table
    self.tableView.backgroundColor = [colors objectForKey:@"background"];
    self.tableView.tintColor = [colors objectForKey:@"tint"];
    self.cellBackgroundColor = [colors objectForKey:@"cellBackground"];
    self.startsDateLabel.textColor = [colors objectForKey:@"tint"];
    self.endsDateLabel.textColor = [colors objectForKey:@"tint"];
    // Nav bar
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:21.0],
                                                                    NSForegroundColorAttributeName : [colors objectForKey:@"colorText"]};
    self.navigationController.navigationBar.barTintColor = [colors objectForKey:@"background"];

    // Text fields
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kNameTextFieldPlaceholder
                                                                               attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    
    self.descriptionTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kDescriptionTextFieldTextFieldPlaceholder
                                                                               attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    self.nameTextField.textColor = [colors objectForKey:@"tint"];
    self.descriptionTextField.textColor = [colors objectForKey:@"tint"];

}

- (void)setupDateLabels
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *now = [NSDate date];
    self.startsDateLabel.text = [self.dateFormatter stringFromDate:now];
    self.startsDateLabel.textColor = [self.tableView tintColor];
    
    self.endsDateLabel.text = kEndsDateDefaultString;
    self.endsDateLabel.textColor = [self.tableView tintColor];
}

- (void)setupDatePickers
{
    // Load Start Date picker
    self.startsDatePicker = [[UIDatePicker alloc] init];
    self.startsDatePicker.hidden = YES;
    self.startsDatePicker.tag = 0;
    self.startsDatePicker.date = [NSDate date];
    [self.startsDatePicker addTarget:self action:@selector(pickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    NSIndexPath *startDatePickerIndexPath = [NSIndexPath indexPathForRow:kStartDatePickerIndex inSection:kDatePickerSection];
    UITableViewCell *startDatePickerCell = [self.tableView cellForRowAtIndexPath:startDatePickerIndexPath];
    [startDatePickerCell.contentView addSubview:self.startsDatePicker];
    
    // Load End Date picker
    self.endsDatePicker = [[UIDatePicker alloc] init];
    self.endsDatePicker.hidden = YES;
    self.endsDatePicker.tag = 1;
    [self.endsDatePicker addTarget:self action:@selector(pickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    self.endsDatePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:60]; // add +60sec
    self.endsDatePicker.date = self.startsDatePicker.date;
    NSIndexPath *endDatePickerIndexPath = [NSIndexPath indexPathForRow:kEndDatePickerIndex inSection:kDatePickerSection];
    UITableViewCell *endDatePickerCell = [self.tableView cellForRowAtIndexPath:endDatePickerIndexPath];
    [endDatePickerCell.contentView addSubview:self.endsDatePicker];
    
    // Reload cells with pickers in the table view
    [self.tableView reloadRowsAtIndexPaths:@[startDatePickerIndexPath, endDatePickerIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)signUpForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

# pragma mark - TableView Setup

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    // Set height = 0 for hidden date pickers
    if (indexPath.section == kDatePickerSection && indexPath.row == kStartDatePickerIndex) {
        height = (self.startsDatePicker.isHidden || self.startsDatePicker == nil) ? 0 : kDatePickerCellHeight;
    } else if (indexPath.section == kDatePickerSection && indexPath.row == kEndDatePickerIndex) {
        height =  (self.endsDatePicker.isHidden || self.endsDatePicker == nil) ? 0 : kDatePickerCellHeight;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ((indexPath.row != kNameCellIndex) || (indexPath.section != kTextFieldSection) || (indexPath.row != kDescriptionCellIndex)) {
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextField resignFirstResponder];
    }
    
    if (indexPath.row == kStartDatePickerIndex - 1 && indexPath.section == kDatePickerSection) {
        // Hide/show Start Date picker
        self.startsDatePicker.isHidden ? [self showCellForDatePicker:self.startsDatePicker] : [self hideCellForDatePicker:self.startsDatePicker];
        [self hideCellForDatePicker:self.endsDatePicker];
    } else if (indexPath.row == kEndDatePickerIndex - 1 && indexPath.section == kDatePickerSection) {
        // Hide/show End Date picker
        [self hideCellForDatePicker:self.startsDatePicker];
        self.endsDatePicker.isHidden ? [self showCellForDatePicker:self.endsDatePicker] : [self hideCellForDatePicker:self.endsDatePicker];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = self.cellBackgroundColor;
}

#pragma mark - Show/Hide date pickers

- (void)showCellForDatePicker:(UIDatePicker *)datePicker
{
    datePicker.hidden = NO;
    datePicker.alpha = 0.0f;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.38 animations:^{
        datePicker.alpha = 1.0f;
    }];
}


- (void)hideCellForDatePicker:(UIDatePicker *)datePicker
{
    datePicker.hidden = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         datePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         datePicker.hidden = YES;
                     }];
}

- (IBAction)pickerDateChanged:(UIDatePicker *)sender
{
    if (sender.tag == 0) {
        // Start Date Picker Changed
        self.startsDateLabel.text = [self.dateFormatter stringFromDate:sender.date];
        NSDate *laterDate = [self.startsDatePicker.date laterDate:[NSDate date]];
        self.endsDatePicker.minimumDate = [laterDate dateByAddingTimeInterval:60]; // add +30sec
    } else if (sender.tag == 1) {
        // End Date Picker Changed
        if (self.endsDateLabel.text.length == 0) {
            self.endsDateLabel.alpha = 0.0f;
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.endsDateLabel.alpha = 1.0f;
                             }];
        }
        self.endsDateLabel.text = [self.dateFormatter stringFromDate:sender.date];
    }
}

#pragma mark - Cancel / Save

- (IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButton:(id)sender
{
    if (self.nameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kErrorEmptyNameTitle
                                                            message:kErrorEmptyNameMessage
                                                           delegate:nil
                                                  cancelButtonTitle:kErrorEmptyNameCancel
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        SKEvent *newEvent = [[SKDataManager sharedManager] createEventWithName:self.nameTextField.text
                                                                     startDate:self.startsDatePicker.date
                                                                       endDate:self.endsDatePicker.date
                                                                       details:self.descriptionTextField.text];
        [[SKDataManager sharedManager] saveContext];
        NSLog(@"Saved: %@", newEvent);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)keyboardWillShow
{
    !self.startsDatePicker.isHidden ? [self hideCellForDatePicker:self.startsDatePicker] : nil;
    !self.endsDatePicker.isHidden ? [self hideCellForDatePicker:self.endsDatePicker] : nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        // Swith to description text field from name text field
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextField becomeFirstResponder];
    }
    else {
        [self.descriptionTextField resignFirstResponder];
        // Show the firts date picker and hide the second one
        [self showCellForDatePicker:self.startsDatePicker];
        [self hideCellForDatePicker:self.endsDatePicker];
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
