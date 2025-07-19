const app = require('./app');
const PORT = process.env.PORT || 5000;
const userRoutes = require('./routes/users');
app.use('/api/users', userRoutes);


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
