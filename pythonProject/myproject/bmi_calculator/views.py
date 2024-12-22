from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
# import datetime
from django.template import loader
# from myproject import templates


def hello(request):
    # now = datetime.datetime.now()
    # html = "<html><body><h3>Now time is %s.</h3></body></html>" % now
    template = loader.get_template("index.html")
    name = {
        'student' : 'Santhosh'
    }
    return HttpResponse(template.render(name))
