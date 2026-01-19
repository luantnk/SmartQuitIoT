import React, { useEffect, useState } from 'react';
import { Calendar, Clock, Search, TrendingUp, Newspaper, ArrowRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import newsService from '@/services/newsService';

const News = () => {
  const navigate = useNavigate();
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredNews, setFilteredNews] = useState([]);

  useEffect(() => {
    const fetchNews = async () => {
      try {
        setLoading(true);
        const data = await newsService.getAll();
        const newsArray = Array.isArray(data) ? data : [];
        setNews(newsArray);
        setFilteredNews(newsArray);
      } catch (error) {
        console.error('Failed to fetch news:', error);
        setNews([]);
        setFilteredNews([]);
      } finally {
        setLoading(false);
      }
    };

    fetchNews();
  }, []);

  useEffect(() => {
    if (searchQuery.trim() === '') {
      setFilteredNews(news);
    } else {
      const filtered = news.filter(item =>
        item.title?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.content?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredNews(filtered);
    }
  }, [searchQuery, news]);

  const formatDate = (dateString) => {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        month: 'long',
        day: 'numeric',
        year: 'numeric',
      });
    } catch (e) {
      return '';
    }
  };

  const getTimeAgo = (dateString) => {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now - date;
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
      
      if (diffDays === 0) return 'Today';
      if (diffDays === 1) return 'Yesterday';
      if (diffDays < 7) return `${diffDays} days ago`;
      if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
      return `${Math.floor(diffDays / 30)} months ago`;
    } catch (e) {
      return '';
    }
  };

  // Featured news (latest one)
  const featuredNews = filteredNews.length > 0 ? filteredNews[0] : null;
  const regularNews = filteredNews.slice(1);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
        <div className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-16">
          <div className="max-w-7xl mx-auto px-6">
            <div className="animate-pulse">
              <div className="h-8 bg-white/20 rounded w-48 mb-4"></div>
              <div className="h-12 bg-white/30 rounded w-96"></div>
            </div>
          </div>
        </div>
        <div className="max-w-7xl mx-auto px-6 py-12">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div key={i} className="bg-white rounded-2xl shadow-lg overflow-hidden animate-pulse">
                <div className="h-48 bg-gray-200"></div>
                <div className="p-6 space-y-3">
                  <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                  <div className="h-4 bg-gray-200 rounded"></div>
                  <div className="h-4 bg-gray-200 rounded w-5/6"></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-16">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-center gap-2 mb-4">
            <Newspaper className="w-8 h-8" />
            <span className="text-emerald-100 font-semibold">NEWS & UPDATES</span>
          </div>
          <h1 className="text-5xl font-bold mb-4">
            Latest News & Insights
          </h1>
          <p className="text-xl text-emerald-50 max-w-2xl">
            Stay informed with the latest research, tips, and success stories about smoking cessation
          </p>
        </div>
      </div>

      {/* Search Bar */}
      <div className="max-w-7xl mx-auto px-6 -mt-6">
        <div className="bg-white rounded-xl shadow-lg p-4">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Search news articles..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>
        </div>
      </div>

      {/* Featured News */}
      {featuredNews && (
        <div className="max-w-7xl mx-auto px-6 py-12">
          <div className="flex items-center gap-2 mb-6">
            <TrendingUp className="w-6 h-6 text-emerald-600" />
            <h2 className="text-2xl font-bold text-gray-900">Featured Story</h2>
          </div>
          
          <article className="bg-white rounded-2xl shadow-xl overflow-hidden hover:shadow-2xl transition-shadow">
            <div className="grid lg:grid-cols-2 gap-8">
              <div className="relative h-64 lg:h-auto bg-gradient-to-br from-emerald-100 to-teal-100">
                {featuredNews.thumbnailUrl ? (
                  <img
                    src={featuredNews.thumbnailUrl}
                    alt={featuredNews.title}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <Newspaper className="w-24 h-24 text-gray-300" />
                  </div>
                )}
                <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent"></div>
              </div>
              
              <div className="p-8 flex flex-col justify-center">
                <div className="flex items-center gap-4 text-sm text-gray-500 mb-4">
                  <div className="flex items-center gap-2">
                    <Calendar className="w-4 h-4" />
                    <span>{formatDate(featuredNews.createdAt)}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 h-4" />
                    <span>{getTimeAgo(featuredNews.createdAt)}</span>
                  </div>
                </div>
                
                <h3 className="text-3xl font-bold text-gray-900 mb-4">
                  {featuredNews.title}
                </h3>
                
                <p className="text-gray-600 text-lg mb-6 line-clamp-4">
                  {featuredNews.content || 'Read this featured article to discover the latest insights and updates...'}
                </p>
                
                <button 
                  onClick={() => navigate(`/news/${featuredNews.id}`)}
                  className="inline-flex items-center gap-2 text-emerald-600 font-semibold hover:gap-3 transition-all"
                >
                  <span>Read Full Article</span>
                  <ArrowRight className="w-5 h-5" />
                </button>
              </div>
            </div>
          </article>
        </div>
      )}

      {/* All News Grid */}
      <div className="max-w-7xl mx-auto px-6 pb-16">
        {regularNews.length > 0 ? (
          <>
            <h2 className="text-3xl font-bold text-gray-900 mb-8">All Articles</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {regularNews.map((item) => (
                <article
                  key={item.id}
                  onClick={() => navigate(`/news/${item.id}`)}
                  className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer group"
                >
                  {/* Image */}
                  <div className="relative h-48 overflow-hidden bg-gradient-to-br from-emerald-100 to-teal-100">
                    {item.thumbnailUrl ? (
                      <img
                        src={item.thumbnailUrl}
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Newspaper className="w-16 h-16 text-gray-300" />
                      </div>
                    )}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
                  </div>

                  {/* Content */}
                  <div className="p-6">
                    {/* Date */}
                    <div className="flex items-center justify-between text-sm text-gray-500 mb-3">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        <span>{formatDate(item.createdAt)}</span>
                      </div>
                      <span className="text-emerald-600 font-medium">{getTimeAgo(item.createdAt)}</span>
                    </div>

                    {/* Title */}
                    <h3 className="text-xl font-bold text-gray-900 mb-3 line-clamp-2 group-hover:text-emerald-600 transition-colors">
                      {item.title}
                    </h3>

                    {/* Excerpt */}
                    <p className="text-gray-600 text-sm line-clamp-3 mb-4">
                      {item.content || 'Read more to discover valuable insights and information...'}
                    </p>

                    {/* Read More Link */}
                    <div className="flex items-center gap-2 text-emerald-600 font-semibold group-hover:gap-3 transition-all">
                      <span>Read Article</span>
                      <ArrowRight className="w-4 h-4" />
                    </div>
                  </div>
                </article>
              ))}
            </div>
          </>
        ) : (
          <div className="text-center py-16">
            <Newspaper className="w-20 h-20 text-gray-300 mx-auto mb-4" />
            <h3 className="text-2xl font-bold text-gray-900 mb-2">
              {searchQuery ? 'No results found' : 'No news available'}
            </h3>
            <p className="text-gray-600">
              {searchQuery ? 'Try adjusting your search terms' : 'Check back later for updates'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default News;