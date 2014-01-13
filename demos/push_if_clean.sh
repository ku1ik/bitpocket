if [ -n "$(git status --porcelain)" ]; then
  echo "repo is not clean. please cleanup first.";
else
  echo "repo is clean, pulling"
  bitpocket pull

  if [ -n "$(git status --porcelain)" ]; then
    echo "there are new files from the server. please cleanup first.";
  else
    bitpocket push
    echo "successfully pushed";
  fi
fi

