git clone --filter=blob:none --sparse https://github.com/hymaia/hymaclaudeskills.git
cd hymaclaudeskills
git sparse-checkout set pptx-hymaia
mv pptx-hymaia/$SKILL_NAME ~/.claude/skills/$SKILL_NAME