#!/bin/bash

echo "Validating unified auth fixes..."
echo "==============================="

# Check if the modified files exist and have no obvious syntax errors
FILES=(
  "lib/core/auth/auth_manager_impl.dart"
  "lib/core/auth/auth_manager.dart"
  "lib/features/web_view_activity/domain/providers.dart"
  "lib/features/web_view_activity/data/activity_repository_refactored.dart"
  "lib/shared/providers/auth_providers.dart"
)

echo "Checking file existence..."
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ $file exists"
  else
    echo "❌ $file does not exist"
  fi
done

echo ""
echo "Checking for common syntax issues..."

# Check for unclosed brackets, parentheses
echo "Checking for bracket balance..."
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    open_braces=$(grep -o '{' "$file" | wc -l)
    close_braces=$(grep -o '}' "$file" | wc -l)
    if [ "$open_braces" -eq "$close_braces" ]; then
      echo "✅ $file: Braces balanced ($open_braces pairs)"
    else
      echo "❌ $file: Braces unbalanced (open: $open_braces, close: $close_braces)"
    fi
  fi
done

# Check for import issues
echo ""
echo "Checking imports..."
grep -n "import" lib/core/auth/auth_manager_impl.dart | head -15
echo ""

# Check for duplicate declarations (basic check)
echo "Checking for potential duplicate declarations in auth_manager_impl.dart..."
if grep -n "final authState" lib/core/auth/auth_manager_impl.dart; then
  echo "Found authState declarations - verify they are not duplicated"
else
  echo "✅ No obvious duplicate authState declarations found"
fi

echo ""
echo "Validation complete!"
echo "Note: This is a basic syntax check. Full validation requires flutter analyze."