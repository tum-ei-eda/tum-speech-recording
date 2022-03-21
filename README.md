# TUM Speech Recording

TUM Speech Recording is a small web application that collects short snippets of speech. It's designed to help gather open speech data sets to train machine learning systems.

## Use

*Disclaimer: This is a work in progress and currently only tested on Ubuntu 18.04!*

### Collect data
- Open a terminal
- Create a python virtual environment `python3 -m venv venv`
- Activate the virtual environment `. ./venv/bin/activate`
- Install dependencies `pip install -r requirements.txt`
- Launch the application `python app.py`
- Open `http://localhost:8080/` in a Chrome Incognito Window
- Follow the steps: Collect and download the data
- Finally, close application `CTRL+C`

### Post Process
- Install ffmpeg `sudo apt-get install ffmpeg`
- Run the post processing script `./process.sh`
- Upload the zipfile created in the `recordings/` directory

## Background
As with any machine learning, problem data is key. In our case, we are interested in short audio samples that each contain a single keyword, like "yes", "no", "up", or "down". These short labelled audio samples will then be used to train our machine learning model. Additionally, we might want to feed our models some noise only samples, such that it knows what background noise, i.e. silence, looks like. The process of collecting, preparing, and labelling these audio samples can be quite cumbersome. It is not unusual for this process to be the most time-consuming part of the development process, along with the actual training of the model. But because our model will only be as good as the data it sees, we need to ensure that our training data set is as high quality and as extensive as possible.

When looking into acquiring training data for machine learning, there are usually two main options: Using already existing data sets or collecting your own data. Both have their obvious advantages and drawback. Generally speaking, if there already exist training data tests, you would be foolish not to use them. However, you might find that for your specific problem, there is no data available yet. Thus, you have no other option than to collect your own data.

In our application case of KWS, we are lucky to have already a great training data set available free of charge. Thanks to [Pete Warden](https://arxiv.org/pdf/1804.03209.pdf) from Google, we can abstain from having to collect thousands of audio snippets. He started a big campaign a couple of years ago in which he and many other people collected thousands of words into 1-second clips each.

However, since we want our model also to be able to recognize the keyword "TUM", which we probably won't be able to find in any public audio dataset, we will have to collect our own samples. For that, we will be utilizing a modified version of the tool that Pete used when he collected his data set. It is a simple web application that allows us to collect many data samples from colleagues and friends.

## Credits
Based on prior work from [Harvard CS249r](https://github.com/tinyMLx/open-speech-recording) and [Pete Warden](https://github.com/petewarden/open-speech-recording).  
