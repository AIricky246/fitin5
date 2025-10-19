# Fit in 5 - Testing Guide

## Quick Start

### Installation
```bash
flutter pub get
flutter run
```

## Testing Each Feature

### 1. Test Local Storage Persistence
**Steps:**
1. Go to "Exercises" tab
2. Click "Complete" on any exercise
3. Close the app completely
4. Reopen the app
5. Go to "Progress" tab
6. **Expected**: Workout count should still be there

### 2. Test Mark Workouts as Completed
**Exercises Tab:**
1. Click "Complete" button on any exercise
2. **Expected**: 
   - Button turns grey and shows "Done"
   - Exercise name gets strikethrough
   - Success message appears
   - Progress updates

**Generator Tab:**
1. Select 5 minutes and "Easy"
2. Click "Generate Workout"
3. Click "Complete" on individual exercises
4. **Expected**: Each exercise marks as done
5. Click "Complete All" button
6. **Expected**: All remaining exercises mark as done

### 3. Test More Exercises
**Exercises Tab:**
1. Scroll through the list
2. **Expected**: See 15 different exercises
3. Each should have:
   - Name and description
   - Difficulty badge (Easy/Medium)
   - Icon indicator
   - Complete button

### 4. Test Animations & UI Polish
**Visual Feedback:**
1. Complete an exercise
2. **Expected**: Smooth color transition, strikethrough text
3. Go to Progress tab
4. **Expected**: Bar chart updates smoothly
5. Click Reset button
6. **Expected**: Confirmation dialog appears

### 5. Test All Buttons

#### Home Tab
- Feature cards display correctly

#### Exercises Tab
- ✅ Complete buttons work
- ✅ Buttons disable when already completed

#### Generate Tab
- ✅ Time buttons (5, 10, 15 min) - select one
- ✅ Difficulty buttons (Easy, Medium) - select one
- ✅ Generate Workout button - creates list
- ✅ Complete buttons on each exercise
- ✅ Complete All button - marks all as done

#### Progress Tab
- ✅ Reset button - clears data with confirmation
- ✅ Bar chart shows daily progress
- ✅ Statistics update correctly

## Expected Behavior

### Completing a Workout
- Button changes from green to grey
- Text shows "Done" instead of "Complete"
- Exercise name gets strikethrough
- SnackBar shows success message
- Progress counter increments

### Generating a Workout
- Selecting time and difficulty enables Generate button
- Generates random exercises matching criteria
- Each exercise shows in numbered list
- Can complete individually or all at once

### Progress Tracking
- Shows total workouts this week
- Bar chart shows daily breakdown
- Statistics show average, best day, days active
- Reset button clears all data with confirmation

### Data Persistence
- All data saves automatically
- Survives app restart
- Survives device restart
- Can be reset manually

## Troubleshooting

**Buttons not responding:**
- Make sure you've selected time and difficulty before generating
- Check that app has permission to use storage

**Data not saving:**
- Check device storage is available
- Try resetting and trying again

**UI looks wrong:**
- Make sure you're using Flutter 3.9.2 or later
- Run `flutter clean` and `flutter pub get`

## Success Criteria
✅ All buttons are clickable and functional
✅ Data persists after app restart
✅ Workouts can be marked as completed
✅ Progress is tracked and displayed
✅ UI provides clear visual feedback
✅ All 15 exercises are available
✅ Animations are smooth

