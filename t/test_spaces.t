#!/bin/sh

test_description='Test gitifyhg clone, pull, and push with spaces'

source ./test-lib.sh

# if ! test_have_prereq PYTHON; then
#    skip_all='skipping gitifyhg tests; python not available'
#    test_done
# fi

# if ! "$PYTHON_PATH" -c 'import mercurial'; then
#    skip_all='skipping gitifyhg tests; mercurial not available'
#    test_done
# fi

test_expect_success 'clone branch with spaces' '
    test_when_finished "rm -rf hg_repo git_clone" &&
    make_hg_repo &&
    hg branch "feature branch" &&
    make_hg_commit b test_file &&
    clone_repo &&
    assert_git_messages "a" &&
    test "`git branch -r`" = "  origin/HEAD -> origin/master
  origin/branches/feature___branch
  origin/master" &&

    git checkout branches/feature___branch &&
    test_cmp ../hg_repo/test_file test_file &&
    assert_git_messages "b${NL}a" &&

    cd ..

'

test_expect_success 'clone bookmark with spaces' '
    test_when_finished "rm -rf hg_repo git_clone" &&
    make_hg_repo &&
    hg bookmark "feature bookmark"
    make_hg_commit b test_file

    clone_repo

    test "`git branch -r`" = "  origin/HEAD -> origin/master
  origin/feature___bookmark
  origin/master" &&

    git checkout origin/feature___bookmark &&
    assert_git_messages "b${NL}a" &&
    git checkout master &&
    assert_git_messages "b${NL}a" &&

    cd ..
'

test_expect_success 'clone tag with spaces' '
    test_when_finished "rm -rf hg_repo git_clone" &&

    make_hg_repo &&
    make_hg_commit b test_file &&
    hg tag "this is tagged" &&
    make_hg_commit c test_file &&

    clone_repo &&

    test $(git tag) = "this___is___tagged" &&
    git checkout this___is___tagged &&
    assert_git_messages "b${NL}a" &&

    cd ..
'

test_expect_success 'push to named branch with spaces' '
    test_when_finished "rm -rf hg_repo git_clone" &&

    make_hg_repo &&
    hg branch "branch one" &&
    make_hg_commit b test_file &&

    clone_repo &&
    git checkout -t "origin/branches/branch___one" &&
    make_git_commit c test_file &&
    git push &&

    cd ../hg_repo &&
    hg log --template="{desc}\n" &&
    assert_hg_messages "c${NL}b${NL}a" &&
    hg update tip &&
    test "`hg branch`" == "branch one" &&

    cd ..
'

test_expect_success 'push to bookmark with spaces' '
    test_when_finished "rm -rf hg_repo git_clone" &&

    make_hg_repo &&
    hg bookmark "feature bookmark" &&
    make_hg_commit b test_file &&
    clone_repo &&
    git checkout --track origin/feature___bookmark &&
    make_git_commit c test_file &&
    git push &&

    cd ../hg_repo &&
    hg update &&

    assert_hg_messages "c${NL}b${NL}a" &&
    hg bookmark | grep "feature bookmark" &&
    hg update "feature bookmark" &&
    test_cmp test_file ../git_clone/test_file &&

    cd ..
'

test_done
