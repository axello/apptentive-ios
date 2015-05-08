//
//  ATPersonDetailsViewController.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/19/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATPersonDetailsViewController.h"
#import "ATBackend.h"
#import "ATConnect_Private.h"
#import "ATPersonInfo.h"
#import "ATInfoViewController.h"
#import "ATUtilities.h"

enum kPersonDetailsTableSections {
	kContactInfoSection,
	kForgetInfoSection,
	kSectionCount
};


@interface ATPersonDetailsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *logoButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UILabel *poweredByLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@end

@implementation ATPersonDetailsViewController {
	UIEdgeInsets previousScrollInsets;
	UILabel *emailValidationLabel;
	UIAlertView *emailRequiredAlert;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	emailRequiredAlert.delegate = nil;
}

- (void)viewDidUnload {
	self.nameTextField.delegate = nil;
	self.emailTextField.delegate = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self setTableView:nil];
	[self setLogoButton:nil];
	[self setEmailCell:nil];
	[self setNameCell:nil];
	[self setEmailTextField:nil];
	[self setNameTextField:nil];
	[self setPoweredByLabel:nil];
	[self setLogoImage:nil];
	emailValidationLabel = nil;
	[super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if ([self.tableView respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
		[self.tableView setAccessibilityIdentifier:@"ATContactInfoTable"];
	}
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	self.nameTextField.placeholder = ATLocalizedString(@"Name", @"Placeholder text for `Name` field when editing user details.");
	if ([[ATConnect sharedConnection] emailRequired]) {
		self.emailTextField.placeholder = ATLocalizedString(@"Email (required)", @"Email Address Field Placeholder (email is required)");
	} else {
		self.emailTextField.placeholder = ATLocalizedString(@"Email", @"Placeholder text for `Email` field when editing user details.");
	}
	
	if ([ATPersonInfo currentPerson] != nil) {
		ATPersonInfo *person = [ATPersonInfo currentPerson];
		self.nameTextField.text = person.name;
		self.emailTextField.text = person.emailAddress;
	}
	self.navigationItem.title = ATLocalizedString(@"Contact Settings", @"Title of contact information edit screen");
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.logoButton.bounds.size.height, 0);
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
	previousScrollInsets = self.tableView.contentInset;
	UIImage *buttonBackgroundImage = [[ATBackend imageNamed:@"at_contact_button_bg"] stretchableImageWithLeftCapWidth:1 topCapHeight:40];
	[self.logoButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
	if (![ATBackend sharedBackend].hideBranding) {
		self.logoImage.image = [ATBackend imageNamed:@"at_apptentive_logo"];
		self.poweredByLabel.text = ATLocalizedString(@"Message Center Powered By", @"Text above Apptentive logo");
		self.logoImage.hidden = NO;
		self.poweredByLabel.hidden = NO;
		self.logoButton.hidden = NO;
	} else {
		self.logoImage.hidden = YES;
		self.poweredByLabel.hidden = YES;
		self.logoButton.hidden = YES;
	}
	[self registerForKeyboardNotifications];
	[self.emailTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
	emailValidationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width - 10, 20)];
	emailValidationLabel.text = ATLocalizedString(@"Please enter a valid email address.", @"Table footer asking for a valid email address.");
	emailValidationLabel.textColor = [UIColor redColor];
	emailValidationLabel.font = [UIFont systemFontOfSize:15];
	emailValidationLabel.shadowColor = [UIColor whiteColor];
	emailValidationLabel.shadowOffset = CGSizeMake(0, 1);
	emailValidationLabel.textAlignment = NSTextAlignmentCenter;
	emailValidationLabel.numberOfLines = 0;
	emailValidationLabel.lineBreakMode = NSLineBreakByWordWrapping;
	emailValidationLabel.backgroundColor = [UIColor clearColor];
	emailValidationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	CGSize s = [emailValidationLabel sizeThatFits:CGSizeMake(self.tableView.bounds.size.width - 10, 1000)];
	s.height = MAX(s.height, 25);
	CGRect f = emailValidationLabel.frame;
	f.size = s;
	emailValidationLabel.frame = f;
	
	emailValidationLabel.hidden = [self emailIsValid];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.emailTextField resignFirstResponder];
	[self.nameTextField resignFirstResponder];
	[self savePersonData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.emailTextField resignFirstResponder];
	[self.nameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)savePersonData {
	if ([[ATConnect sharedConnection] emailRequired] && self.emailTextField.text.length == 0) {
		return NO;
	}
	
	if (![self emailIsValid]) {
		return NO;
	}
	ATPersonInfo *person = [ATPersonInfo currentPerson] ?: [[ATPersonInfo alloc] init];

	NSString *emailAddress = self.emailTextField.text;
	NSString *name = self.nameTextField.text;
	if (emailAddress && ![emailAddress isEqualToString:person.emailAddress]) {
		// Do not save empty string as person's email address
		if (emailAddress.length > 0) {
			person.emailAddress = emailAddress;
			person.needsUpdate = YES;
		}
		
		// Deleted email address from form, then submitted.
		if ([emailAddress isEqualToString:@""] && person.emailAddress) {
			person.emailAddress = @"";
			person.needsUpdate = YES;
		}
	}
	
	if (name && ![name isEqualToString:person.name]) {
		person.name = name;
		person.needsUpdate = YES;
	}
	[person saveAsCurrentPerson];
	return YES;
}

- (BOOL)emailIsValid {
	NSString *email = self.emailTextField.text;
	if (email && [email length] > 0) {
		return [ATUtilities emailAddressIsValid:email];
	}
	return YES;
}

- (void)showEmailRequiredAlert {
	if (emailRequiredAlert) {
		return;
	}
	NSString *title = ATLocalizedString(@"Please enter an email address", @"Email is required and no email was entered alert title.");
	NSString *message = ATLocalizedString(@"An email address is required for us to respond.", @"Email is required and no email was entered alert message.");
	emailRequiredAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:ATLocalizedString(@"OK", @"OK button title"), nil];
	[emailRequiredAlert show];
}

- (IBAction)donePressed:(id)sender {
	if ([[ATConnect sharedConnection] emailRequired] && self.emailTextField.text.length == 0) {
		[self showEmailRequiredAlert];
	} else if ([self savePersonData]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)logoPressed:(id)sender {
	ATInfoViewController *vc = [[ATInfoViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
	vc = nil;
}

- (BOOL)disablesAutomaticKeyboardDismissal {
	return NO;
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kContactInfoSection) {
        return 2;
    } else if (section == kForgetInfoSection) {
		return 1;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == kContactInfoSection) {
		return emailValidationLabel;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == kContactInfoSection) {
		return emailValidationLabel.bounds.size.height;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ATForgetInfoCellIdentifier = @"ATForgetInfoCell";
	
	UITableViewCell *cell = nil;
	if (indexPath.section == kForgetInfoSection) {
		cell = [tableView dequeueReusableCellWithIdentifier:ATForgetInfoCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ATForgetInfoCellIdentifier];
			cell.accessoryView = nil;
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = ATLocalizedString(@"Forget Info", @"Title of button to forget contact information");
	} else if (indexPath.section == kContactInfoSection) {
		if (indexPath.row == 0) {
			cell = self.emailCell;
		} else if (indexPath.row == 1) {
			cell = self.nameCell;
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kForgetInfoSection) {
		self.emailTextField.text = @"";
		self.nameTextField.text = @"";
		if ([[ATConnect sharedConnection] emailRequired] && self.emailTextField.text.length == 0) {
			[self showEmailRequiredAlert];
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = nil;
	if (section == kContactInfoSection) {
		title = ATLocalizedString(@"Contact Info", @"Title of contact information section");
	}
	return title;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:self.emailTextField]) {
		[self.nameTextField becomeFirstResponder];
		return YES;
	} else if ([textField isEqual:self.nameTextField]) {
		[self.nameTextField resignFirstResponder];
		return YES;
	}
	return YES;
}

- (void)textFieldChanged:(id)sender {
	emailValidationLabel.hidden = [self emailIsValid];
	
	if ([[ATConnect sharedConnection] emailRequired] && self.emailTextField.text.length == 0) {
		[self showEmailRequiredAlert];
	}
}

#pragma mark Keyboard Handling

- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

+ (UIView *)topLevelViewForView:(UIView *)v {
	if (v.superview == nil) {
		return v;
	} else if ([v.superview isKindOfClass:[UIWindow class]]) {
		return v;
	} else {
		return [self topLevelViewForView:v.superview];
	}
}

- (void)keyboardWillBeShown:(NSNotification *)aNotification {
	NSDictionary *info = [aNotification userInfo];
	CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGRect kbAdjustedFrame = [self.tableView.window convertRect:kbFrame toView:self.tableView];
	
	CGRect scrollFrame = self.tableView.frame;
	CGRect intersection = CGRectIntersection(kbAdjustedFrame, scrollFrame);
	CGFloat offset = intersection.size.height;
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, offset, 0);
	self.tableView.contentInset = contentInsets;
	self.tableView.scrollIndicatorInsets = contentInsets;
	
	UITextField *activeField = nil;
	if ([self.emailTextField isFirstResponder]) {
		activeField = self.emailTextField;
	} else if ([self.nameTextField isFirstResponder]) {
		activeField = self.nameTextField;
	}
	if (activeField) {
		CGRect scrollFrame = self.tableView.frame;
		scrollFrame.size.height -= offset;
		CGRect visibleRect = [self.tableView convertRect:activeField.frame fromView:activeField.superview];
		if (!CGRectContainsRect(scrollFrame, visibleRect)) {
			[self.tableView scrollRectToVisible:visibleRect animated:YES];
		}
	}
	self.tableView.showsVerticalScrollIndicator = YES;
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
	NSNumber *duration = [[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSNumber *curve = [[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	UITableView *t = self.tableView;
	[UIView animateWithDuration:[duration floatValue] delay:0 options:[curve intValue] animations:^{
		t.contentInset = previousScrollInsets;
		t.scrollIndicatorInsets = previousScrollInsets;
	} completion:NULL];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (emailRequiredAlert && [alertView isEqual:emailRequiredAlert]) {
		emailRequiredAlert.delegate = nil;
		emailRequiredAlert = nil;
		[self.emailTextField becomeFirstResponder];
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	if (emailRequiredAlert && [alertView isEqual:emailRequiredAlert]) {
		emailRequiredAlert.delegate = nil;
		emailRequiredAlert = nil;
	}
}

@end
