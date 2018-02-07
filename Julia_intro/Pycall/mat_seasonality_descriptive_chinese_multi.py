# -*- coding: utf-8 -*-
__author__ = 'Think'
import sqlite3
import csv
import matplotlib.font_manager as font_manager
import re
import numpy as np
import json
import datetime
from matplotlib.patches import Ellipse
import matplotlib.pyplot as plt
from matplotlib.dates import YEARLY, DateFormatter, rrulewrapper, RRuleLocator, drange
import matplotlib.dates as mdates
import matplotlib.path as path
import matplotlib.patches as patches
import matplotlib.cbook as cbook
import ch
import sys
reload(sys)
sys.setdefaultencoding('utf8')
ch.set_ch()

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------   Seasonality   -------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

mean = []
std_upper = []
std_lower = []
pagefile = file('C:\\working\\cs\\Wanda_final\\support\\m_s_2.csv', 'rb')
pagereader = csv.reader(pagefile)
for row in pagereader:
    mean.append(float(row[0]))
    std_upper.append(float(row[1]))
    std_lower.append(float(row[2]))
pagefile.close()
print len(mean)
print mean
print std_upper
print std_lower


pattern2 = re.compile(u'\d+')

begin = datetime.date(2013, 7, 20)
end = datetime.date(2016, 3, 17)
descriptive_date = []
for i in range((end - begin).days+1):
    day = begin + datetime.timedelta(days=i)
    descriptive_date.append(day)

print len(descriptive_date)


# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------   USA's film   --------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

def daily_ratio(date):
    s = (date - begin).days
    return mean[s]

print daily_ratio(datetime.date(2014,1,31))

totallist = []
pagefile = file('C:\\working\\cs\\Mtime_final\\support\\filmname_mtime.csv', 'rb')
pagereader = csv.reader(pagefile)
for row in pagereader:
    totallist.append(row[0])
pagefile.close()
totallist2 = list(set(totallist))
print totallist2

print '-'*20
conn = sqlite3.connect('Mtime2.db')
print "Opened database successfully"
cursor = conn.execute("SELECT ID, COUNTRY_MADE FROM moviemade")
count = cursor.fetchall()
print "operation done successfully"
conn.close()

print '-'*20

conn2 = sqlite3.connect('Mtime2.db')
print "Opened database successfully"
cursor2 = conn2.execute("SELECT ID, COUNTRY, RELEASEDATE FROM releasedate")
count2 = cursor2.fetchall()
print "operation done successfully"
conn2.close()
# print count2


print '-'*20
conn3 = sqlite3.connect('Cbooo.db')
print "Opened database successfully"
cursor3 = conn3.execute("SELECT * FROM filmbox")
count3 = cursor3.fetchall()
print "operation done successfully"
conn.close()
print count3

print '-'*20

date_list = []
pattern2 = re.compile(u'\d+')


print '-'*20

list_CN = []
list_USA = []
list_Not_CN = []
list_HK = []
list_TW = []


list_made= []
for item in count:
    list_made.append(item[0])
print "list of made country"
# print list_made

# print len(list(set(list_made)))


print '-'*20

for item in count:
    if item[1]==u'中国':
        list_CN.append(item[0])
    else:
        pass

print list_CN
print '-'*20


for item in count:
    if item[1]==u'美国':
        list_USA.append(item[0])
    else:
        # print "film %r meets some error" % item[0]
        pass

print list_USA
print '-'*20


for item in count:
    if item[1]==u'中国台湾':
        list_TW.append(item[0])
    else:
        pass
print "TW film : %r" % len(list_TW)
print list_TW
print '-'*20
print '-'*20

for item in count:
    if item[1]==u'中国香港':
        list_HK.append(item[0])
    else:
        pass

print "HK film : %r" % len(list_HK)
print list_HK
print '-'*20




list_USA_strict = []
for item in list_USA:
    if item not in list_CN:
        list_USA_strict.append(item)
    else:
        pass

print list_USA_strict
print '-'*20

list_CN_HK =list(set(list_CN).union(set(list_HK)))

print "total film numbers %r" % len(totallist2)
print "total film made %r" % len(list_made)
print "Chinese film: %r" % len(list_CN)
print "Chinese_HK film: %r" % len(list_CN_HK)
print "USA film: %r" % len(list_USA)
print "Strict USA film: %r" % len(list_USA_strict)
print "Non-Chinese film: %r" % len(list_Not_CN)
print "len of release info: %r" % len(count2)

def release_func(inputid):
    outdate = []
    for item in count2:
        if inputid ==item [0] and item[1]==u'China':
            outdate.append(item[2])
            unic_outdate = outdate[0]
            matchdate = re.findall(pattern2, unic_outdate)
            dateout = datetime.date(int(matchdate[0]),int(matchdate[1]),int(matchdate[2]))
            return dateout
        else:
            pass
    print " %r releasing information missing" % inputid
    failfile = open("homerelease_func_fail.txt", 'a')
    failfile.write(str(inputid) + "meets release error \n")
    failfile.close()
    return None

print release_func(193463)
print release_func(194879)
print release_func(206162)
print release_func(193463)
print len(count2)



announcement = []
announcement_file = file("announcement.csv", 'rb')
announcement_reader = csv.reader(announcement_file)
for row in announcement_reader:
    cache_announcement = []
    cache_announcement.append(int(row[0]))
    cache_announcement.append(datetime.date(int(re.findall(pattern2, row[5])[0]),int(re.findall(pattern2, row[5])[1]),int(re.findall(pattern2, row[5])[2])))
    announcement.append(cache_announcement)

print announcement


def announcement_func(Mtime_id):
    for item in announcement:
        if item[0] ==Mtime_id:
            return item[1]
        else:
            pass
    return None




def box_func(id):
    for item in count3:
        if item[0] == id:
            return item[1]








release = []
for i in list_USA_strict:
    pic_1 = []
    pic_1.append(i)
    box_cache = []
    for k in count3:
        if k[0] == i:
            box_cache.append(k[1])
        else:
            pass

    if not box_cache:
        continue

    pic_1.append(box_cache[0])

    try:
        # ---------------  usa releasing date  -----------------------------
        usa_cache =[]
        for j in count2:
            if j[0] == i and j[1] ==u'USA':
                matchdate = re.findall(pattern2, j[2])
                dateusa = datetime.date(int(matchdate[0]),int(matchdate[1]),int(matchdate[2]))
                # print dateusa

                if not usa_cache:
                    usa_cache.append(dateusa)
                else:
                    if dateusa>usa_cache[0]:
                        usa_cache[0]=dateusa
                    else:
                        pass
            else:
                pass

        pic_1.append(usa_cache[0])

        # ---------------  cn box data  -----------------------------


        # ---------------  cn releasing date  -----------------------------

        cn_cache =[]
        for m in count2:
            if m[0] == i and m[1] ==u'China':
                matchdate = re.findall(pattern2, m[2])
                datecn = datetime.date(int(matchdate[0]),int(matchdate[1]),int(matchdate[2]))
                # print datecn
                # datecn = str(matchdate[0])+'-'+ str(matchdate[1])+'-'+str(matchdate[2])
                if not cn_cache:
                    cn_cache.append(datecn)
                else:
                    if datecn>cn_cache[0]:
                        usa_cache[0]=datecn
                    else:
                        pass

                # USA_y.append(matchdate[0])
                # USA_m.append(matchdate[1])
                # USA_d.append(matchdate[2])
            else:
                pass

        pic_1.append(cn_cache[0])


        release.append(pic_1)

    except IndexError,e:
        print "film %r meets some error" % str(i)



print release
print len(release)


dates_usa = []
dates_cn = []
mat_box =[]
date_delay = []
dates_id = []

for item in release:
    if item[3]>datetime.date(2013,3,1) and item[2]>datetime.date(2012,1,1):
        dates_id.append(item[0])
        dates_usa.append(item[2])
        dates_cn.append(item[3])
        mat_box.append(item[1])
        date_delay.append(float((item[3]-item[2]).days)/365)


print len(dates_cn)



print date_delay[:10]

area1 = np.array(mat_box)
dates_usa_np = np.array(dates_usa)
delay_colors = np.array(date_delay)
# print dates_usa_np

area = area1/100
# print area


# ----------------------------all use firm ------------------------------------
Scatter_ratio = []
Scatter_date = []
Scatter_size = []
Scatter_delay = []
for i in range(len(dates_cn)):
    if dates_cn[i] > datetime.date(2013,7,20) and dates_cn[i] < datetime.date(2016,3,17):
        Scatter_ratio.append(daily_ratio(dates_cn[i]))
        Scatter_date.append(dates_cn[i])
        Scatter_size.append(area[i])
        Scatter_delay.append(delay_colors[i])

colors = Scatter_delay
Scatter_size2 = np.array(Scatter_size)


# ------------------------------distinct type (type 1 and type 2)--------------
Scatter_ratio_1 = []
Scatter_date_1 = []
Scatter_size_1 = []
Scatter_delay_1 = []
Scatter_ratio_2 = []
Scatter_date_2 = []
Scatter_size_2 = []
Scatter_delay_2 = []

for i in range(len(dates_cn)):
    # test_date_announcement = dates_usa[i] + datetime.timedelta(days=14)
    test_date_announcement = dates_usa[i]
    # if dates_cn[i] > datetime.date(2013,7,20) and dates_cn[i] < datetime.date(2016,3,17) and announcement_func(dates_id[i]) >= test_date_announcement:
    if dates_cn[i] > datetime.date(2013,7,20) and dates_cn[i] < datetime.date(2016,3,17) and announcement_func(dates_id[i]) >= test_date_announcement:
        Scatter_ratio_1.append(daily_ratio(dates_cn[i]))
        Scatter_date_1.append(dates_cn[i])
        Scatter_size_1.append(area[i])
        Scatter_delay_1.append(delay_colors[i])
    elif dates_cn[i] > datetime.date(2013,7,20) and dates_cn[i] < datetime.date(2016,3,17) and announcement_func(dates_id[i]) < test_date_announcement:
        Scatter_ratio_2.append(daily_ratio(dates_cn[i]))
        Scatter_date_2.append(dates_cn[i])
        Scatter_size_2.append(area[i])
        Scatter_delay_2.append(delay_colors[i])
    else:
        pass

print len(Scatter_date_1)
print len(Scatter_date_2)

colors_type1 = Scatter_delay_1
colors_type2 = Scatter_delay_2
Scatter_size2_type1 = np.array(Scatter_size_1)
Scatter_size2_type2 = np.array(Scatter_size_2)




# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# ------------------------------------   Chinese film  --------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
Scatter_CN_id = []
Scatter_CN_date = []
Scatter_CN_box = []
Scatter_CN_name = []
Scatter_CN_daily_ratio = []
# print count2
for i in count3:
    if i[0] in list_CN and i[1] > 10000:
        print i
print '-'*30

# ---------------------------------------------------------------------------------
# -------------------------------   box selector   --------------------------------
# ---------------------------------------------------------------------------------
for line in count3:
    if line[0] in list_CN and line[1] > 10000 and release_func(line[0])> datetime.date(2013,7,20) and release_func(line[0])< datetime.date(2016,3,18):
        print repr(line[0])
        Scatter_CN_id.append(line[0])
        Scatter_CN_date.append(release_func(line[0]))
        Scatter_CN_box.append(box_func(line[0]))
        Scatter_CN_daily_ratio.append(daily_ratio(release_func(line[0])))
        Scatter_CN_name.append(line[2])



area_CN = np.array(Scatter_CN_box)
Plot_area_CN = area_CN/100
Plot_area_CN2 = np.array(Plot_area_CN)


print (Scatter_CN_date)
print len(Scatter_CN_box)
print (Scatter_CN_id)
print len(Scatter_CN_daily_ratio)
print len(Scatter_CN_name)

print Scatter_CN_daily_ratio
print Scatter_CN_date
print Plot_area_CN2

print Scatter_date
print Scatter_ratio
print Scatter_size2



# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# ------------------------------------   Wanda's daily data  --------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------


file = open("Wanda_chinese_json.txt")
content = file.read()


dict_loads = json.loads(content)

list_chinese_number = dict_loads["list_chinese_number"]
list_all_film = dict_loads["list_all_number"]

print type(dict_loads)
# print dict["list_date"]
print len(list_chinese_number)
print list_chinese_number[:10]
print list_all_film[:10]
#
print '-'*30


# ----------------------------------------------all film cohort --------------------------------------------
avg_number =[]
avg_date = []
begin1 = datetime.date(2013, 7, 20)
end1 = datetime.date(2016, 3, 17)
for i in range((end1 - begin1).days+1):
    avg_date.append(begin1 + datetime.timedelta(days=i))
    cache_number = np.array(list_chinese_number[i])
    movie_number = np.mean(cache_number)
    avg_number.append(movie_number)

avg_date.append(datetime.date(2016,3,18))
print len(avg_number)
print len(avg_date)
number_mean = np.mean(np.array(avg_number))
#


print len(avg_date)
print avg_date[-3:]
print len(avg_number)
print avg_number[-3:]
print "mean value of number is %r" % number_mean

def daily_number(date):
    date_delta = (date - begin1).days
    if date.year==2013:
        return avg_number[date_delta] - number_mean*(638/649.2)
    elif date.year==2014:
        return avg_number[date_delta] - number_mean*(618/649.2)
    elif date.year==2015:
        return avg_number[date_delta] - number_mean*(686/649.2)
    else:
        return avg_number[date_delta] - number_mean

print daily_number(datetime.date(2016,3,17))

left_positive = []
right_positive = []
top_positive = []
left_negative = []
right_negative = []
top_negative = []
for i in range(len(avg_number)):
    date_func_cache = begin1 + datetime.timedelta(days=i)
    number_func_cache = daily_number(date_func_cache)
    if number_func_cache >= 0:
        left_positive.append(mdates.date2num(date_func_cache))
        right_positive.append(mdates.date2num(date_func_cache + datetime.timedelta(days=1)))
        top_positive.append(number_func_cache)
    else:
        left_negative.append(mdates.date2num(date_func_cache))
        right_negative.append(mdates.date2num(date_func_cache + datetime.timedelta(days=1)))
        top_negative.append(number_func_cache)

print len(left_positive)
print len(left_negative)
print left_positive[-5:]
bottom_positive = np.zeros(len(left_positive))
bottom_negative = np.zeros(len(left_negative))
top_positive = np.array(top_positive)
top_negative = np.array(top_negative)

XY_positive = np.array([[left_positive, left_positive, right_positive, right_positive], [bottom_positive, top_positive, top_positive, bottom_positive]]).T
XY_negative = np.array([[left_negative, left_negative, right_negative, right_negative], [bottom_negative, top_negative, top_negative, bottom_negative]]).T

barpath_positive = path.Path.make_compound_path_from_polys(XY_positive)
barpath_negative = path.Path.make_compound_path_from_polys(XY_negative)

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# ------------------------------------   plot   ---------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

el = Ellipse((2, -1), 0.5, 0.5)

years = mdates.YearLocator()
months = mdates.MonthLocator(interval=2)
mondays = mdates.WeekdayLocator(mdates.MONDAY)

yearsFmt = mdates.DateFormatter("%y-%m-%d")


plt.rc('axes', grid=True)
plt.rc('grid', color='0.75', linestyle='-', linewidth=0.5)

textsize = 9
left, width = 0.1, 0.8
rect1 = [left, 0.3, width, 0.6]
rect2 = [left, 0.1, width, 0.2]


fig = plt.figure(facecolor='white')
axescolor = '#f6f6f6'  # the axes background color

ax1 = fig.add_axes(rect1, axisbg=axescolor)  # left, bottom, width, height

# ax2t = ax2.twinx()
# ax3 = fig.add_axes(rect3, axisbg=axescolor, sharex=ax1)


# datemin = begin
datemin = datetime.date(2013, 7, 1)
# datemax = end,
datemax = datetime.date(2016,4, 1)
ratiomax = 0.035
ratiomin = 0.0
ax1.set_xlim(datemin, datemax)
ax1.set_ylim(ratiomin,ratiomax)


ls = ax1.plot_date(descriptive_date, mean, '-', c='black', linewidth=1.25, label=u'Average industry Share')
ls_std1 = ax1.plot_date(descriptive_date, std_lower, '--', c='lightblue',linewidth=1.25)
ls_std2 = ax1.plot_date(descriptive_date, std_upper, '--', c='lightblue', linewidth=1.25)

ax1.xaxis.set_major_locator(months)
ax1.xaxis.set_major_formatter(yearsFmt)
labels = ax1.get_xticklabels()
plt.setp(labels, rotation=30, fontsize=10)


# ax1.set_xticks([])
ax1.set_xticklabels([])


ax1.spines['right'].set_visible(False)
ax1.spines['top'].set_visible(False)
ax1.xaxis.set_ticks_position('bottom')

ax1.annotate(u'Protection window\n  ', xy=(datetime.date(2013,8,10), 0.012), xycoords='data',
            xytext=(-50, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )


ax1.annotate(u'National Day', xy=(datetime.date(2013, 10, 1), 0.012), xycoords='data',
            xytext=(-25, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )


ax1.annotate(u'Xmas and New Year', xy=(datetime.date(2013,12,27), 0.012), xycoords='data',
            xytext=(-35, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )


ax1.annotate(u'Spring Festival', xy=(datetime.date(2014,1,31), 0.021), xycoords='data',
            xytext=(-30, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Spring Festival', xy=(datetime.date(2015,2,19), 0.028), xycoords='data',
            xytext=(-30, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Protection window', xy=(datetime.date(2014,8,1), 0.021), xycoords='data',
            xytext=(-50, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Protection window', xy=(datetime.date(2015,7,24), 0.028), xycoords='data',
            xytext=(-50, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'National Day', xy=(datetime.date(2014,10,1), 0.021), xycoords='data',
            xytext=(-25, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Xmas and New Year', xy=(datetime.date(2014,12,28), 0.021), xycoords='data',
            xytext=(-35, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'National Day', xy=(datetime.date(2015,10,1), 0.028), xycoords='data',
            xytext=(-25, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Xmas and New Year', xy=(datetime.date(2015,12,27), 0.028), xycoords='data',
            xytext=(-35, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'    outlier\n (速度与激情7)', xy=(datetime.date(2015, 4, 15), 0.018), xycoords='data',
            xytext=(-20, 55), textcoords='offset points',
            size=10,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

ax1.annotate(u'Spring Festival', xy=(datetime.date(2016, 2, 10), 0.030), xycoords='data',
            xytext=(-30, 25), textcoords='offset points',
            size=12,
            # bbox=dict(boxstyle="round", fc="0.8"),
            arrowprops=dict(arrowstyle="fancy",
                            fc="0.6", ec="none",
                            patchB=el,
                            connectionstyle="angle3,angleA=0,angleB=-90"),
            )

# plt.scatter(Scatter_date, Scatter_ratio,s=Scatter_size2, c='dodgerblue', alpha=0.4)
# sc1 = ax1.scatter(Scatter_date, Scatter_ratio,s=Scatter_size2, c="#9999ff", alpha=0.6, label=u'美国电影')
sc1_1 = ax1.scatter(Scatter_date_1, Scatter_ratio_1,s=Scatter_size2_type1, c="#9999ff", alpha=0.6, label=u'Naked US films')
sc1_2 = ax1.scatter(Scatter_date_2, Scatter_ratio_2,s=Scatter_size2_type2, c="dodgerblue", alpha=0.6, label=u'non-Naked US films')
# plt.scatter(Scatter_CN_date, Scatter_CN_daily_ratio,s=Plot_area_CN2, c='red', alpha=0.4)
sc2 = ax1.scatter(Scatter_CN_date, Scatter_CN_daily_ratio,s=Plot_area_CN2, c='#ff9999', alpha=0.6, label=u'homegrown films (box office larger than 100m yuan)')
sc1_3 = ax1.scatter(datetime.date(2013,1,1), 0.01,s=2000,c="whitesmoke" , alpha=0.6, label=u'Size:box office in mainland China')

ax1.autoscale_view()
# ax1.xaxis.grid(False, 'major')
# ax1.xaxis.grid(True, 'minor')
ax1.grid(True)

ax2 = fig.add_axes(rect2, axisbg=axescolor)
#
# ax2.annotate(u'影院日均在映\n国产影片数:4.7 ', xy=(datetime.date(2016, 3, 18), 0), xycoords='data',
#             xytext=(-15, 25), textcoords='offset points',
#             size=15,
#             # bbox=dict(boxstyle="round", fc="0.8"),
#             arrowprops=dict(arrowstyle="fancy",
#                             fc="0.6", ec="none",
#                             patchB=el,
#                             connectionstyle="angle3,angleA=0,angleB=-90"),
#             )



numbermax = 6
numbermin = -4

ax2.set_yticks([ -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6])
ax2.set_yticklabels([ "-4", "-3", "-2", "-1", "(4.7) 0", "1", "2", "3", "4", "5", ""])
ax2.set_yticklabels([ "-4 (0.7)", "-3 (1.7)", " -2 (2.7)", "-1 (3.7)", "0 (4.7)", "1 (5.7)", "2 (6.7)", "3 (7.7)", "4 (8.7)", "5 (9.7)", ""])


patch_positive = patches.PathPatch(
    barpath_positive, facecolor='red', edgecolor='gray', alpha=0.6, label=u'The average number of ')
patch_negative = patches.PathPatch(
    barpath_negative, facecolor='green', edgecolor='gray', alpha=0.6, label=u'homegrown films on')

ax2.add_patch(patch_positive)
ax2.add_patch(patch_negative)


ax2.set_xlim(datemin, datemax)

ax2.xaxis.set_major_locator(months)
ax2.xaxis.set_major_formatter(yearsFmt)
labels = ax2.get_xticklabels()
plt.setp(labels, fontsize=10)

ax2.spines['right'].set_visible(False)
# ax2.spines['top'].set_visible(False)
ax2.xaxis.set_ticks_position('bottom')


ax2.set_ylim(numbermin,numbermax)
ax2.spines['right'].set_visible(False)
# ax2.spines['top'].set_visible(False)
fig.autofmt_xdate()

# ax2.set_ylabel(u'影院日均在映国产影片数')
plt.xlabel(u'Time', fontsize= 15)
# ax1.set_title(u'国产电影')

fig.suptitle(u'China\'s Movie Market', fontsize=18, fontweight='bold')

# plt.title(u'Chinese Movie Industry', fontsize=15)
# ax1.axis('equal')




# leg = ax1.legend(loc=0, numpoints=1,frameon=False, handlelength=3.5, handleheight=2.5, scatterpoints=1)
leg1 = ax1.legend(loc=0, numpoints=1, handlelength=3.5, handleheight=2, scatterpoints=1, shadow=False, fancybox=True, fontsize=15)
# leg = plt.gca().get_legend()
leg1.get_frame().set_alpha(0.5)

# leg2 = ax2.legend(loc=2, numpoints=1, handlelength=3.5, handleheight=1,  shadow=False, fancybox=True, fontsize=15)
leg2 = ax2.legend(handles=[patch_positive,patch_negative], loc=2, numpoints=1, handlelength=3.5, handleheight=1, shadow=False, fancybox=True,fontsize=15)
leg2.get_frame().set_alpha(0.2)
# leg = plt.gca().get_legend()


fig.set_size_inches(24, 12, forward=True)
fig.savefig('CN_movie_industry.png', dpi=400)

plt.show()

